CREATE DATABASE  IF NOT EXISTS `pramod_hospital_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `pramod_hospital_db`;
-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: pramod_hospital_db
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admins`
--

DROP TABLE IF EXISTS `admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admins` (
  `admin_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  PRIMARY KEY (`admin_id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admins`
--

LOCK TABLES `admins` WRITE;
/*!40000 ALTER TABLE `admins` DISABLE KEYS */;
INSERT INTO `admins` VALUES (1,'superadmin','scrypt:32768:8:1$randomsalt$hashedvalue...');
/*!40000 ALTER TABLE `admins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `appointments`
--

DROP TABLE IF EXISTS `appointments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointments` (
  `appointment_id` int NOT NULL AUTO_INCREMENT,
  `patient_id` int NOT NULL,
  `doctor_id` int NOT NULL,
  `appointment_date` datetime NOT NULL,
  `status` enum('Scheduled','Completed','Cancelled') DEFAULT 'Scheduled',
  PRIMARY KEY (`appointment_id`),
  KEY `patient_id` (`patient_id`),
  KEY `doctor_id` (`doctor_id`),
  KEY `idx_appointment_date` (`appointment_date`),
  CONSTRAINT `appointments_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `appointments_ibfk_2` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointments`
--

LOCK TABLES `appointments` WRITE;
/*!40000 ALTER TABLE `appointments` DISABLE KEYS */;
INSERT INTO `appointments` VALUES (3,1,5,'2026-05-28 13:28:00','Scheduled'),(5,1,5,'2026-05-28 13:47:00','Scheduled'),(8,1,5,'2026-05-27 12:54:00','Completed'),(10,1,5,'2026-05-28 12:15:00','Scheduled'),(11,1,5,'2026-05-28 12:21:00','Scheduled'),(12,1,5,'2026-05-28 12:35:00','Scheduled'),(13,1,5,'2026-05-28 10:49:00','Scheduled'),(14,2,5,'2026-05-29 13:50:00','Completed'),(15,2,9,'2026-05-29 14:03:00','Completed');
/*!40000 ALTER TABLE `appointments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctors`
--

DROP TABLE IF EXISTS `doctors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctors` (
  `doctor_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `name` varchar(100) NOT NULL,
  `specialization` varchar(100) NOT NULL,
  `qualification` varchar(100) NOT NULL,
  `consultation_fee` decimal(10,2) NOT NULL,
  PRIMARY KEY (`doctor_id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctors`
--

LOCK TABLES `doctors` WRITE;
/*!40000 ALTER TABLE `doctors` DISABLE KEYS */;
INSERT INTO `doctors` VALUES (5,'suresh','scrypt:32768:8:1$AG1XC3vjeWgSdmTL$4725e2d4fdf2710a5b40005c78675a8fa5447f33319f159d13ee7f00c6632d019d7630c7eeb3edaa61798243d3302aab2470f73959593beedaf9396af0a25c93','S.Suresh','Gastroenterology','MBBS,MD',299.00),(6,'rohini','scrypt:32768:8:1$GIg6RKkADGBcMkIY$5b1f687d7e09ce67cd6744a1cce33ddd2928381ed48cba92ebac59e0943a27076a9e10d463dd3c10f78bc97026acf1c4413c89486ab24d5741e79a7a1704921c','Y.Rohini','ENT Specialist','MS ENT',200.00),(7,'yashodha','scrypt:32768:8:1$w39fLXbJFB1BMzaB$66ed6e3a81c6144b4ebec2c816b2ad990b097a3fc1e039e9aff5e353e5248dc0a5d228531dfee86e1d224b45e737ede0bbcabfecc7e5b3907f7391deb2b5af6f','S.Yashodha','Cardiologist','MD Medicine ,DM Cardiology',500.00),(8,'rohan','scrypt:32768:8:1$lv1DKVfdqc6PdGxd$0c3032cb7f0c784e741b5916e8c06a9affe805d931acd52320e7db7935df3d829e90ffff55bd1909815d39fc8f30c13401738b4860fde82693667384885314a4','Y.Rohan','Dermatologist','MD Dermatologist',300.00),(9,'rakesh','scrypt:32768:8:1$ONyV5X3Z1nfbtm3t$d8022c7758d89497ba2d3867d3f92ba22b9376e26840a09fcd10b01312402fbce6db48c1451a660ac7394961434be4be240a87b0b113371124fee2c4f9c06f47','S.Rakesh','Psychiatrist','MD Psychiatrist',400.00);
/*!40000 ALTER TABLE `doctors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoices` (
  `invoice_id` int NOT NULL AUTO_INCREMENT,
  `appointment_id` int NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_status` enum('Pending','Paid') DEFAULT 'Pending',
  `issued_date` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`invoice_id`),
  KEY `appointment_id` (`appointment_id`),
  CONSTRAINT `invoices_ibfk_1` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
INSERT INTO `invoices` VALUES (3,8,299.00,'Pending','2026-05-27 09:52:58'),(4,14,299.00,'Paid','2026-05-27 10:51:59'),(5,15,400.00,'Paid','2026-05-27 11:00:34');
/*!40000 ALTER TABLE `invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patients`
--

DROP TABLE IF EXISTS `patients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patients` (
  `patient_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `age` int DEFAULT NULL,
  `gender` enum('Male','Female','Other') DEFAULT NULL,
  `contact_number` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`patient_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `contact_number` (`contact_number`),
  KEY `idx_username` (`username`),
  CONSTRAINT `patients_chk_1` CHECK ((`age` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patients`
--

LOCK TABLES `patients` WRITE;
/*!40000 ALTER TABLE `patients` DISABLE KEYS */;
INSERT INTO `patients` VALUES (1,'Anu','scrypt:32768:8:1$jtk96xgBUucJmt8c$278ea525cf91eb9bcd5c6c8e262951d2f08c17ef9312d59114a7a37155296fcd83a01f92ead0dbf114dafae3080b8d907ed5862e7f2ef4b0177ba88f40868191','T.Anuradha',NULL,NULL,NULL),(2,'ravi','scrypt:32768:8:1$5SJCgF4k4qgYD7YU$2a940c98b98f9b0b93d8d5cf32fe13fda1272359f8a09d06ebd93cf1cb6bcdf2be742833fe49244814aa20c2fd5c56bcb747bd4b0b0d8d139651950ee733fef1','T.Ravi',NULL,NULL,NULL);
/*!40000 ALTER TABLE `patients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prescriptions`
--

DROP TABLE IF EXISTS `prescriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prescriptions` (
  `prescription_id` int NOT NULL AUTO_INCREMENT,
  `appointment_id` int NOT NULL,
  `medicines` text NOT NULL,
  `dosage_instructions` text NOT NULL,
  `issued_date` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`prescription_id`),
  KEY `appointment_id` (`appointment_id`),
  CONSTRAINT `prescriptions_ibfk_1` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prescriptions`
--

LOCK TABLES `prescriptions` WRITE;
/*!40000 ALTER TABLE `prescriptions` DISABLE KEYS */;
INSERT INTO `prescriptions` VALUES (1,8,'paracetmol 200mg','take thrice per days ','2026-05-27 09:52:58'),(2,14,'dolo 650','4 times daily','2026-05-27 10:51:59'),(3,15,'cefixime 200mg','mrng-evng','2026-05-27 11:00:34');
/*!40000 ALTER TABLE `prescriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `upcoming_schedules`
--

DROP TABLE IF EXISTS `upcoming_schedules`;
/*!50001 DROP VIEW IF EXISTS `upcoming_schedules`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `upcoming_schedules` AS SELECT 
 1 AS `appointment_id`,
 1 AS `patient_name`,
 1 AS `doctor_name`,
 1 AS `appointment_date`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `upcoming_schedules`
--

/*!50001 DROP VIEW IF EXISTS `upcoming_schedules`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `upcoming_schedules` AS select `a`.`appointment_id` AS `appointment_id`,`p`.`full_name` AS `patient_name`,`d`.`name` AS `doctor_name`,`a`.`appointment_date` AS `appointment_date` from ((`appointments` `a` join `patients` `p` on((`a`.`patient_id` = `p`.`patient_id`))) join `doctors` `d` on((`a`.`doctor_id` = `d`.`doctor_id`))) where ((`a`.`status` = 'Scheduled') and (`a`.`appointment_date` > now())) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-27 11:16:07
