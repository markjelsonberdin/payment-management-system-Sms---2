-- Clean Phase 1 Schema (Merged)
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


CREATE TABLE `students` (
  `student_id` int(10) UNSIGNED NOT NULL,
  `student_number` varchar(50) NOT NULL,
  `full_name` varchar(150) NOT NULL,
  `course_id` varchar(100) DEFAULT NULL,
  `year_level` varchar(20) DEFAULT NULL,
  `status` varchar(50) DEFAULT 'Enrolled',
  `last_sync_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`student_id`),
  UNIQUE KEY `student_number` (`student_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `fee_categories` (
  `category_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `category_name` varchar(100) NOT NULL,
  `priority_order` int(11) NOT NULL DEFAULT 0,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `fees` (
  `fee_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `category_id` int(10) UNSIGNED DEFAULT NULL,
  `fee_name` varchar(100) NOT NULL,
  `default_amount` decimal(10,2) NOT NULL,
  `is_required` tinyint(1) DEFAULT 1,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`fee_id`),
  KEY `fk_fees_category` (`category_id`),
  CONSTRAINT `fk_fees_category` FOREIGN KEY (`category_id`) REFERENCES `fee_categories` (`category_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `billing` (
  `billing_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `student_id` int(10) UNSIGNED NOT NULL,
  `generated_by` int(10) UNSIGNED DEFAULT NULL,
  `billing_type` enum('Enrollment','Assessment','Adjustment') NOT NULL,
  `academic_year` varchar(20) NOT NULL,
  `semester` enum('1st','2nd','Summer') NOT NULL,
  `total_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `discount_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `remaining_balance` decimal(10,2) NOT NULL DEFAULT 0.00,
  `billing_status` enum('Unpaid','Partial','Paid') DEFAULT 'Unpaid',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`billing_id`),
  KEY `student_id` (`student_id`),
  KEY `generated_by` (`generated_by`),
  KEY `idx_billing_status` (`billing_status`),
  CONSTRAINT `billing_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`),
  CONSTRAINT `chk_billing_discount` CHECK (`discount_amount` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `scholarships` (
  `scholarship_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `student_id` int(10) UNSIGNED NOT NULL,
  `billing_id` int(10) UNSIGNED DEFAULT NULL,
  `approved_by` int(10) UNSIGNED DEFAULT NULL,
  `discount_amount` decimal(10,2) DEFAULT NULL,
  `scholarship_name` varchar(100) NOT NULL,
  `discount_type` enum('Percentage','Fixed Amount') NOT NULL,
  `discount_percentage` decimal(5,2) DEFAULT NULL,
  `status` enum('Active','Revoked','Expired') DEFAULT 'Active',
  `approved_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`scholarship_id`),
  KEY `student_id` (`student_id`),
  KEY `billing_id` (`billing_id`),
  CONSTRAINT `scholarships_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_scholarships_billing` FOREIGN KEY (`billing_id`) REFERENCES `billing` (`billing_id`) ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT `chk_discount_amount` CHECK (`discount_amount` IS NULL OR `discount_amount` >= 0),
  CONSTRAINT `chk_discount_percentage` CHECK (`discount_percentage` IS NULL OR (`discount_percentage` >= 0 AND `discount_percentage` <= 100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `billing_items` (
  `billing_item_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `billing_id` int(10) UNSIGNED NOT NULL,
  `fee_id` int(10) UNSIGNED NOT NULL,
  `fee_name` varchar(100) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `paid_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `remaining_amount` decimal(10,2) NOT NULL,
  `status` enum('Unpaid','Partial','Paid') DEFAULT 'Unpaid',
  PRIMARY KEY (`billing_item_id`),
  KEY `billing_id` (`billing_id`),
  KEY `fee_id` (`fee_id`),
  CONSTRAINT `billing_items_ibfk_1` FOREIGN KEY (`billing_id`) REFERENCES `billing` (`billing_id`) ON DELETE CASCADE,
  CONSTRAINT `billing_items_ibfk_2` FOREIGN KEY (`fee_id`) REFERENCES `fees` (`fee_id`),
  CONSTRAINT `chk_billing_items_amount` CHECK (`amount` >= 0),
  CONSTRAINT `chk_billing_items_paid` CHECK (`paid_amount` >= 0),
  CONSTRAINT `chk_billing_items_remaining` CHECK (`remaining_amount` >= 0),
  CONSTRAINT `chk_billing_items_paid_limit` CHECK (`paid_amount` <= `amount`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `payments` (
  `payment_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `student_id` int(10) UNSIGNED NOT NULL,
  `billing_id` int(10) UNSIGNED NOT NULL,
  `verified_by` int(10) UNSIGNED DEFAULT NULL,
  `transaction_type` enum('Walk-in','Online','Payment Concern') NOT NULL,
  `payment_method` enum('Walk-in','Online','Bank Transfer') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `cash_received` decimal(10,2) DEFAULT NULL,
  `change_amount` decimal(10,2) DEFAULT NULL,
  `payment_channel` enum('Cash','GCash','Maya','Visa','Mastercard','Bank','PayMongo') NOT NULL,
  `reference_number` varchar(100) DEFAULT NULL,
  `payment_status` enum('Pending','Verified','Rejected','Failed') DEFAULT 'Pending',
  `payment_date` date NOT NULL,
  `remarks` text DEFAULT NULL,
  `receipt_number` varchar(50) DEFAULT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`payment_id`),
  UNIQUE KEY `reference_number` (`reference_number`),
  UNIQUE KEY `receipt_number` (`receipt_number`),
  KEY `student_id` (`student_id`),
  KEY `billing_id` (`billing_id`),
  KEY `idx_payment_status` (`payment_status`),
  KEY `idx_payment_date` (`payment_date`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`),
  CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`billing_id`) REFERENCES `billing` (`billing_id`),
  CONSTRAINT `chk_payment_amount` CHECK (`amount` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `payment_allocations` (
    `allocation_id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `payment_id` INT(10) UNSIGNED NOT NULL,
    `billing_item_id` INT(10) UNSIGNED NOT NULL,
    `allocated_amount` DECIMAL(10,2) NOT NULL,
    `allocated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`allocation_id`),
    UNIQUE KEY `uq_payment_billing_item` (`payment_id`, `billing_item_id`),
    KEY `idx_allocations_payment` (`payment_id`),
    KEY `idx_allocations_billing_item` (`billing_item_id`),
    CONSTRAINT `fk_allocations_payment` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`payment_id`) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_allocations_billing_item` FOREIGN KEY (`billing_item_id`) REFERENCES `billing_items` (`billing_item_id`) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `chk_allocated_amount` CHECK (`allocated_amount` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `paymongo_transactions` (
    `paymongo_transaction_id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    `payment_id` INT(10) UNSIGNED DEFAULT NULL,
    `checkout_session_id` VARCHAR(150) DEFAULT NULL UNIQUE,
    `payment_intent_id` VARCHAR(150) DEFAULT NULL UNIQUE,
    `paymongo_payment_id` VARCHAR(150) DEFAULT NULL UNIQUE,
    `webhook_event_id` VARCHAR(150) DEFAULT NULL UNIQUE,
    `event_type` VARCHAR(100) DEFAULT NULL,
    `amount` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `convenience_fee` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `total_charged` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    `signature_verified` TINYINT(1) NOT NULL DEFAULT 0,
    `processing_status` ENUM('Received', 'Processing', 'Processed', 'Failed', 'Ignored') NOT NULL DEFAULT 'Received',
    `received_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `processed_at` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`paymongo_transaction_id`),
    KEY `idx_paymongo_payment` (`payment_id`),
    KEY `idx_paymongo_status` (`processing_status`),
    CONSTRAINT `fk_paymongo_transaction_payment` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`payment_id`) ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT `chk_paymongo_amount` CHECK (`amount` > 0),
  CONSTRAINT `chk_paymongo_fee` CHECK (`convenience_fee` >= 0),
  CONSTRAINT `chk_paymongo_total_exact` CHECK (`total_charged` = `amount` + `convenience_fee`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `payment_concerns` (
  `concern_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `payment_id` int(10) UNSIGNED DEFAULT NULL,
  `receipt_path` varchar(255) NOT NULL,
  `verification_status` enum('Pending','Verified','Rejected') DEFAULT 'Pending',
  `ocr_status` enum('Processing','Completed','Failed') DEFAULT 'Processing',
  `remarks` text DEFAULT NULL,
  `reviewed_by` int(10) UNSIGNED DEFAULT NULL,
  `submitted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `reviewed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`concern_id`),
  KEY `payment_id` (`payment_id`),
  CONSTRAINT `payment_concerns_ibfk_1` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`payment_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `ocr_results` (
  `ocr_result_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `concern_id` int(10) UNSIGNED NOT NULL,
  `extracted_amount` decimal(10,2) DEFAULT NULL,
  `bank_name` varchar(100) DEFAULT NULL,
  `confidence_score` decimal(5,2) DEFAULT NULL,
  `reference_number` varchar(100) DEFAULT NULL,
  `transaction_date` date DEFAULT NULL,
  `transaction_time` time DEFAULT NULL,
  `raw_json` JSON DEFAULT NULL,
  PRIMARY KEY (`ocr_result_id`),
  KEY `concern_id` (`concern_id`),
  CONSTRAINT `ocr_results_ibfk_1` FOREIGN KEY (`concern_id`) REFERENCES `payment_concerns` (`concern_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_ocr_confidence` CHECK (`confidence_score` IS NULL OR (`confidence_score` >= 0 AND `confidence_score` <= 100)),
  CONSTRAINT `chk_ocr_amount` CHECK (`extracted_amount` IS NULL OR `extracted_amount` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `payment_gateway_settings` (
  `setting_key` varchar(50) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `payment_settings_audit` (
  `audit_id` int(11) NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(50) DEFAULT NULL,
  `old_value` text DEFAULT NULL,
  `new_value` text DEFAULT NULL,
  `changed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`audit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Inserting default configurations
INSERT INTO `payment_gateway_settings` (`setting_key`, `setting_value`, `description`) VALUES
('channel_card', '1', '1 to Enable, 0 to Disable Credit/Debit Cards'),
('channel_gcash', '1', '1 to Enable, 0 to Disable GCash'),
('channel_maya', '1', '1 to Enable, 0 to Disable Maya'),
('fee_policy', 'pass_to_student', 'pass_to_student or absorb_by_school'),
('gateway_mode', 'test', 'Set to live or test mode'),
('paymongo_public_key', '', 'PayMongo Public Key (Stored in .env)'),
('paymongo_secret_key', '', 'PayMongo Secret Key (Stored in .env)'),
('paymongo_webhook_secret', '', 'Webhook Secret (Stored in .env)');

INSERT INTO `fee_categories` (`category_id`, `category_name`, `priority_order`, `status`) VALUES
(1, 'Tuition', 1, 'Active'),
(2, 'Miscellaneous', 2, 'Active'),
(3, 'Laboratory & Computer', 3, 'Active'),
(4, 'Student Council & Organization', 4, 'Active'),
(5, 'Supplementary Fees', 5, 'Active'),
(6, 'Other', 6, 'Active');

INSERT INTO `fees` (`fee_id`, `category_id`, `fee_name`, `default_amount`, `is_required`, `status`) VALUES
(31, 2, 'Registration', 400.00, 1, 'Active'),
(33, 2, 'Library', 650.00, 1, 'Active'),
(34, 2, 'Athletics & Sports Dev. Fee', 500.00, 1, 'Active'),
(35, 2, 'Cultural Fee', 400.00, 1, 'Active'),
(36, 2, 'Guidance & Counseling', 400.00, 1, 'Active'),
(37, 2, 'Energy Fee', 1000.00, 1, 'Active'),
(38, 2, 'Laboratory Fee', 600.00, 1, 'Active'),
(39, 2, 'Community & Student Dev. Fee', 600.00, 1, 'Active'),
(40, 2, 'Insurance', 25.00, 1, 'Active'),
(41, 2, 'Medical and Dental', 400.00, 1, 'Active'),
(42, 5, 'Student Handbook', 250.00, 1, 'Active'),
(43, 5, 'RFID', 500.00, 1, 'Active'),
(45, 5, 'Research Forum 2026', 200.00, 1, 'Active');
