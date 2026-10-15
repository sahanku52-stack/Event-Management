CREATE TABLE IF NOT EXISTS users (
 id BIGINT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL, email VARCHAR(150) NOT NULL UNIQUE,
 password_hash VARCHAR(100) NOT NULL, role ENUM('ADMIN','ORGANIZER','ATTENDEE') NOT NULL,
 status ENUM('ACTIVE','SUSPENDED') NOT NULL DEFAULT 'ACTIVE', created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
-- jm migrate creates the documented first-run administrator. Its temporary marker is upgraded to BCrypt on first login.
INSERT IGNORE INTO users(name,email,password_hash,role,status)
SELECT 'Administrator','admin@eventmgr.local','__BOOTSTRAP_ADMIN__','ADMIN','ACTIVE'
WHERE NOT EXISTS (SELECT id FROM users WHERE email='admin@eventmgr.local');
CREATE TABLE IF NOT EXISTS events (
 id BIGINT AUTO_INCREMENT PRIMARY KEY, organizer_id BIGINT NOT NULL, title VARCHAR(150) NOT NULL,
 description TEXT NOT NULL, event_date DATE NOT NULL, event_time TIME NOT NULL, venue VARCHAR(200) NOT NULL,
 category VARCHAR(80) NOT NULL DEFAULT 'Community', status ENUM('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, CONSTRAINT fk_event_organizer FOREIGN KEY (organizer_id) REFERENCES users(id) ON DELETE CASCADE,
 INDEX idx_event_date_status(status,event_date)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS tickets (
 id BIGINT AUTO_INCREMENT PRIMARY KEY, event_id BIGINT NOT NULL, name VARCHAR(100) NOT NULL,
 price DECIMAL(10,2) NOT NULL DEFAULT 0, quantity INT NOT NULL DEFAULT 100, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_ticket_event FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS registrations (
 id BIGINT AUTO_INCREMENT PRIMARY KEY, event_id BIGINT NOT NULL, ticket_id BIGINT NOT NULL, attendee_id BIGINT NOT NULL,
 quantity INT NOT NULL DEFAULT 1, total DECIMAL(10,2) NOT NULL DEFAULT 0,
 status ENUM('CONFIRMED','CANCELLED','ATTENDED') NOT NULL DEFAULT 'CONFIRMED', created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 UNIQUE KEY uq_registration(event_id,attendee_id), CONSTRAINT fk_reg_event FOREIGN KEY(event_id) REFERENCES events(id) ON DELETE CASCADE,
 CONSTRAINT fk_reg_ticket FOREIGN KEY(ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
 CONSTRAINT fk_reg_attendee FOREIGN KEY(attendee_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS announcements (
 id BIGINT AUTO_INCREMENT PRIMARY KEY, event_id BIGINT NOT NULL, organizer_id BIGINT NOT NULL,
 body VARCHAR(2000) NOT NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_announcement_event FOREIGN KEY(event_id) REFERENCES events(id) ON DELETE CASCADE,
 CONSTRAINT fk_announcement_organizer FOREIGN KEY(organizer_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS settings(setting_key VARCHAR(50) PRIMARY KEY, setting_value VARCHAR(255) NOT NULL) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS activity_log (
 id BIGINT AUTO_INCREMENT PRIMARY KEY, user_id BIGINT NULL, action VARCHAR(80) NOT NULL,
 detail VARCHAR(255) NOT NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_activity_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE SET NULL,
 INDEX idx_activity_created(created_at)
) ENGINE=InnoDB;
INSERT IGNORE INTO settings(setting_key,setting_value) VALUES ('site_name','EventX'),('contact_email','hello@eventx.local'),('allow_registration','true'),('require_event_approval','true');
