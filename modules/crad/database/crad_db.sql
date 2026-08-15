-- ============================================================
-- CRAD Module Database Schema
-- Database: crad_db
-- Bestlink College of the Philippines — SMS 2
-- ============================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+08:00";

-- ------------------------------------------------------------
-- Table: research_proposals
-- Stores the main submission from submit-documents.php
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `research_proposals` (
    `id`                INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `ref_code`          VARCHAR(30)     NOT NULL UNIQUE COMMENT 'Auto-generated reference e.g. CRD-2026-00001',
    `research_title`    VARCHAR(500)    NOT NULL,
    `program_course`    VARCHAR(200)    NOT NULL,
    `year_section`      VARCHAR(100)    NOT NULL,
    `college_department` VARCHAR(200)   NOT NULL,
    `research_adviser`  VARCHAR(200)    NOT NULL,
    `academic_year`     VARCHAR(20)     NOT NULL,
    -- Representative
    `rep_name`          VARCHAR(200)    NOT NULL,
    `rep_id`            VARCHAR(50)     NOT NULL,
    `rep_email`         VARCHAR(200)    NOT NULL,
    `rep_contact`       VARCHAR(20)     NOT NULL,
    -- Metadata
    `status`            ENUM(
                            'Submitted',
                            'In Progress',
                            'Panel Assigned',
                            'Approved',
                            'Returned'
                        ) NOT NULL DEFAULT 'Submitted',
    `progress`          TINYINT UNSIGNED NOT NULL DEFAULT 0  COMMENT 'Progress % shown in tracking (0=Submitted, 1-99=In Progress, 100=Approved)',
    `date_submitted`    DATE            NOT NULL,
    `signature_data`    MEDIUMTEXT      NULL     COMMENT 'Base64 PNG of representative signature',
    `submitted_by_user` INT UNSIGNED    NULL     COMMENT 'FK to sms2_db users (optional)',
    `notes`             TEXT            NULL     COMMENT 'CRAD officer notes',
    `created_at`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_status`    (`status`),
    KEY `idx_dept`      (`college_department`(50)),
    KEY `idx_submitted` (`date_submitted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ------------------------------------------------------------
-- Table: proposal_members
-- Group members per proposal (up to 5)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `proposal_members` (
    `id`            INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `proposal_id`   INT UNSIGNED    NOT NULL,
    `sort_order`    TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1 = lead member',
    `student_id`    VARCHAR(50)     NOT NULL,
    `student_name`  VARCHAR(200)    NOT NULL,
    `email`         VARCHAR(200)    NOT NULL,
    `contact`       VARCHAR(20)     NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_proposal` (`proposal_id`),
    CONSTRAINT `fk_pm_proposal`
        FOREIGN KEY (`proposal_id`)
        REFERENCES `research_proposals` (`id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ------------------------------------------------------------
-- Table: proposal_documents
-- Uploaded file records per proposal slot
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `proposal_documents` (
    `id`            INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `proposal_id`   INT UNSIGNED    NOT NULL,
    `doc_key`       VARCHAR(60)     NOT NULL COMMENT 'Slot key: manuscript, approval, abstract, etc.',
    `doc_title`     VARCHAR(200)    NOT NULL,
    `original_name` VARCHAR(300)    NOT NULL,
    `stored_name`   VARCHAR(300)    NOT NULL,
    `file_size`     INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT 'Bytes',
    `uploaded_at`   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_pd_proposal` (`proposal_id`),
    CONSTRAINT `fk_pd_proposal`
        FOREIGN KEY (`proposal_id`)
        REFERENCES `research_proposals` (`id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ------------------------------------------------------------
-- Table: proposal_status_logs
-- Audit trail whenever status/progress changes
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `proposal_status_logs` (
    `id`            INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `proposal_id`   INT UNSIGNED    NOT NULL,
    `old_status`    VARCHAR(30)     NULL,
    `new_status`    VARCHAR(30)     NOT NULL,
    `changed_by`    INT UNSIGNED    NULL COMMENT 'FK to sms2_db users',
    `remarks`       TEXT            NULL,
    `changed_at`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_psl_proposal` (`proposal_id`),
    CONSTRAINT `fk_psl_proposal`
        FOREIGN KEY (`proposal_id`)
        REFERENCES `research_proposals` (`id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
