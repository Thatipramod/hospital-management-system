from flask import Flask, request, jsonify, render_template, session, redirect
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
from sqlalchemy import text, func
import re 
import os # NEW: Required for environment variables
from dotenv import load_dotenv # NEW: Loads the .env file

# Load the variables from the .env file into the system
load_dotenv() 

app = Flask(__name__)
# Pull the secrets securely from the environment
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY')
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# ... [The rest of your routes stay exactly the same!]
# ==========================================
# 1. PATIENT ROUTES
# ==========================================
@app.route('/')
def login_page():
    if 'patient_id' in session: return redirect('/dashboard')
    return render_template('login.html')

@app.route('/dashboard')
def dashboard_page():
    if 'patient_id' not in session: return redirect('/')
    return render_template('dashboard.html', name=session.get('full_name'))

@app.route('/api/logout')
def logout():
    session.clear()
    return redirect('/')

@app.route('/api/signup', methods=['POST'])
def signup():
    data = request.json
    
    password = data['password']
    pwd_regex = r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$"
    if not re.match(pwd_regex, password):
        return jsonify({"error": "Password must be at least 8 characters long and include an uppercase letter, a lowercase letter, a number, and a special character."}), 400

    check_sql = text("SELECT patient_id FROM patients WHERE username = :u")
    if db.session.execute(check_sql, {'u': data['username']}).fetchone():
        return jsonify({"error": "Username already exists"}), 400
        
    hashed_pw = generate_password_hash(password)
    insert_sql = text("INSERT INTO patients (username, password_hash, full_name) VALUES (:u, :p, :f)")
    db.session.execute(insert_sql, {'u': data['username'], 'p': hashed_pw, 'f': data['full_name']})
    db.session.commit()
    return jsonify({"message": "Registration successful! Please login."}), 201

@app.route('/api/login', methods=['POST'])
def login():
    data = request.json
    sql = text("SELECT patient_id, password_hash, full_name FROM patients WHERE username = :u")
    user = db.session.execute(sql, {'u': data['username']}).fetchone()
    
    if user and check_password_hash(user.password_hash, data['password']):
        session['patient_id'] = user.patient_id
        session['full_name'] = user.full_name
        return jsonify({"message": "Login successful"}), 200
    return jsonify({"error": "Invalid username or password"}), 401

@app.route('/api/doctors', methods=['GET'])
def get_doctors():
    sql = text("SELECT * FROM doctors")
    result = db.session.execute(sql)
    doctors = [{"id": r.doctor_id, "name": r.name, "spec": r.specialization, "qual": r.qualification, "fee": float(r.consultation_fee)} for r in result]
    return jsonify(doctors), 200

@app.route('/api/book', methods=['POST'])
def book_appointment():
    if 'patient_id' not in session: return jsonify({"error": "Unauthorized"}), 401
    data = request.json
    
    # Convert the string date from the frontend into a Python datetime object
    requested_date = datetime.strptime(data['date'], '%Y-%m-%dT%H:%M')

    # ==========================================
    # DOUBLE-BOOKING PREVENTION LOGIC
    # ==========================================
    # We check if this specific doctor already has an appointment at this exact time
    # We ignore 'Cancelled' appointments because that slot is technically free again.
    check_sql = text("""
        SELECT appointment_id FROM appointments 
        WHERE doctor_id = :d 
        AND appointment_date = :dt 
        AND status != 'Cancelled'
    """)
    conflict = db.session.execute(check_sql, {'d': data['doctor_id'], 'dt': requested_date}).fetchone()
    
    if conflict:
        # 409 is the standard HTTP status code for a "Conflict"
        return jsonify({"error": "This time slot is already booked. Please choose a different time."}), 409

    # ==========================================
    # IF NO CONFLICT, PROCEED WITH BOOKING
    # ==========================================
    try:
        insert_sql = text("INSERT INTO appointments (patient_id, doctor_id, appointment_date) VALUES (:p, :d, :dt)")
        db.session.execute(insert_sql, {'p': session['patient_id'], 'd': data['doctor_id'], 'dt': requested_date})
        db.session.commit()
        return jsonify({"message": f"Appointment successfully booked on {data['date'].replace('T', ' ')}"}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": "Failed to book: " + str(e)}), 400
@app.route('/api/patient/prescriptions', methods=['GET'])
def get_patient_prescriptions():
    if 'patient_id' not in session: return jsonify({"error": "Unauthorized"}), 401
    
    # Unit II & III: Complex INNER JOIN across 3 tables!
    sql = text("""
        SELECT a.appointment_id, d.name AS doctor_name, a.appointment_date, 
               pr.medicines, pr.dosage_instructions, pr.issued_date
        FROM appointments a
        JOIN doctors d ON a.doctor_id = d.doctor_id
        JOIN prescriptions pr ON a.appointment_id = pr.appointment_id
        WHERE a.patient_id = :p_id AND a.status = 'Completed'
        ORDER BY a.appointment_date DESC
    """)
    result = db.session.execute(sql, {'p_id': session['patient_id']})
    
    history = [{
        "appt_id": row.appointment_id,
        "doctor": row.doctor_name,
        "date": str(row.appointment_date).split()[0], # Just get the date part
        "medicines": row.medicines,
        "instructions": row.dosage_instructions
    } for row in result]
    
    return jsonify(history), 200

# ==========================================
# 2. DOCTOR ROUTES
# ==========================================
@app.route('/doctor')
def doctor_login_page():
    if 'doctor_id' in session: return redirect('/doctor/dashboard')
    return render_template('doctor_login.html')

@app.route('/doctor/dashboard')
def doctor_dashboard_page():
    if 'doctor_id' not in session: return redirect('/doctor')
    return render_template('doctor_dashboard.html', name=session.get('doctor_name'))

@app.route('/api/doctor/login', methods=['POST'])
def doctor_login():
    data = request.json
    sql = text("SELECT doctor_id, password_hash, name FROM doctors WHERE username = :u")
    doc = db.session.execute(sql, {'u': data['username']}).fetchone()
    
    if doc and (check_password_hash(doc.password_hash, data['password']) or doc.password_hash == data['password']):
        session['doctor_id'] = doc.doctor_id
        session['doctor_name'] = doc.name
        return jsonify({"message": "Login successful"}), 200
        
    return jsonify({"error": "Invalid doctor credentials"}), 401

@app.route('/api/doctor/signup', methods=['POST'])
def doctor_signup():
    data = request.json
    
    password = data['password']
    pwd_regex = r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$"
    if not re.match(pwd_regex, password):
        return jsonify({"error": "Password must be strong (8+ chars, upper, lower, number, special)."}), 400

    check_sql = text("SELECT doctor_id FROM doctors WHERE username = :u")
    if db.session.execute(check_sql, {'u': data['username']}).fetchone():
        return jsonify({"error": "Username already exists"}), 400
        
    hashed_pw = generate_password_hash(password)
    insert_sql = text("""
        INSERT INTO doctors (username, password_hash, name, specialization, qualification, consultation_fee) 
        VALUES (:u, :p, :n, :s, :q, :c)
    """)
    
    try:
        db.session.execute(insert_sql, {
            'u': data['username'], 'p': hashed_pw, 'n': data['name'], 
            's': data['specialization'], 'q': data['qualification'], 'c': data['fee']
        })
        db.session.commit()
        return jsonify({"message": "Doctor Registration successful! Please login."}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": "Registration failed: " + str(e)}), 400

@app.route('/api/doctor/appointments', methods=['GET'])
def doctor_appointments():
    if 'doctor_id' not in session: return jsonify({"error": "Unauthorized"}), 401
    
    sql = text("""
        SELECT a.appointment_id, p.full_name AS patient_name, a.appointment_date, a.status
        FROM appointments a
        JOIN patients p ON a.patient_id = p.patient_id
        WHERE a.doctor_id = :d_id
        ORDER BY a.appointment_date ASC
    """)
    result = db.session.execute(sql, {'d_id': session['doctor_id']})
    
    appointments = [{
        "id": row.appointment_id, 
        "patient": row.patient_name, 
        "date": str(row.appointment_date), 
        "status": row.status
    } for row in result]
    
    return jsonify(appointments), 200

# ==========================================
# 3. ADMIN & ANALYTICS ROUTES
# ==========================================
@app.route('/admin/dashboard')
def admin_dashboard():
    return render_template('admin_dashboard.html')

@app.route('/api/admin/stats', methods=['GET'])
def get_hospital_stats():
    patient_count = db.session.execute(text("SELECT COUNT(*) FROM patients")).scalar()
    revenue = db.session.execute(text("SELECT SUM(amount) FROM invoices WHERE payment_status = 'Paid'")).scalar() or 0
    
    status_counts = db.session.execute(text("SELECT status, COUNT(*) FROM appointments GROUP BY status")).fetchall()
    chart_data = {row[0]: row[1] for row in status_counts}

    return jsonify({
        "total_patients": patient_count,
        "total_revenue": float(revenue),
        "chart_data": chart_data
    }), 200

# ==========================================
# 4. PRESCRIPTION & BILLING ROUTES
# ==========================================
@app.route('/api/doctor/complete_appointment', methods=['POST'])
def complete_appointment():
    if 'doctor_id' not in session: return jsonify({"error": "Unauthorized"}), 401
    
    data = request.json
    appt_id = data['appointment_id']
    medicines = data['medicines']
    instructions = data['instructions']

    try:
        db.session.execute(text("UPDATE appointments SET status = 'Completed' WHERE appointment_id = :id"), {'id': appt_id})
        
        db.session.execute(text("""
            INSERT INTO prescriptions (appointment_id, medicines, dosage_instructions) 
            VALUES (:a, :m, :i)
        """), {'a': appt_id, 'm': medicines, 'i': instructions})
        
        doc_fee = db.session.execute(text("SELECT consultation_fee FROM doctors WHERE doctor_id = :d"), {'d': session['doctor_id']}).scalar()
        
        db.session.execute(text("""
            INSERT INTO invoices (appointment_id, amount, payment_status) 
            VALUES (:a, :amt, 'Paid')
        """), {'a': appt_id, 'amt': doc_fee})
        
        db.session.commit()
        return jsonify({"message": "Appointment completed, prescription saved, and bill generated!"}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": "Failed process: " + str(e)}), 400

# ==========================================
# 5. PASSWORD RESET 
# ==========================================
@app.route('/api/reset_password', methods=['POST'])
def reset_password():
    data = request.json
    role = data.get('role') 
    username = data.get('username')
    new_password = data.get('new_password')
    
    pwd_regex = r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$"
    if not re.match(pwd_regex, new_password):
        return jsonify({"error": "Password is not strong enough."}), 400

    hashed_pw = generate_password_hash(new_password)

    if role == 'patient':
        sql = text("UPDATE patients SET password_hash = :p WHERE username = :u")
    elif role == 'doctor':
        sql = text("UPDATE doctors SET password_hash = :p WHERE username = :u")
    else:
        return jsonify({"error": "Invalid role"}), 400

    result = db.session.execute(sql, {'p': hashed_pw, 'u': username})
    db.session.commit()

    if result.rowcount == 0:
        return jsonify({"error": "Username not found."}), 404
        
    return jsonify({"message": "Password updated successfully! You can now log in."}), 200

if __name__ == '__main__':
    app.run(debug=True)