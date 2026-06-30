-- V6__missing_academic_tables.sql

-- 1. PASSWORD RESET
CREATE TABLE password_resets (
  id_reset      BIGSERIAL PRIMARY KEY,
  id_user       BIGINT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  email         VARCHAR(150) NOT NULL,
  token         VARCHAR(255) UNIQUE NOT NULL,
  expires_at    TIMESTAMP NOT NULL,
  used          BOOLEAN NOT NULL DEFAULT FALSE,
  used_at       TIMESTAMP,
  ip_address    INET,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT uq_reset_token UNIQUE (token)
);

CREATE INDEX idx_pwd_reset_email  ON password_resets(email);
CREATE INDEX idx_pwd_reset_token  ON password_resets(token);
CREATE INDEX idx_pwd_reset_user   ON password_resets(id_user);

-- 2. EMAIL VERIFICATIONS
CREATE TABLE email_verifications (
  id_verification BIGSERIAL PRIMARY KEY,
  id_user         BIGINT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  email           VARCHAR(150) NOT NULL,
  token           VARCHAR(255) UNIQUE NOT NULL,
  expires_at      TIMESTAMP NOT NULL,
  verified        BOOLEAN NOT NULL DEFAULT FALSE,
  verified_at     TIMESTAMP,
  ip_address      INET,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_email_verif_user  ON email_verifications(id_user);
CREATE INDEX idx_email_verif_token ON email_verifications(token);

-- 3. SESSIONS
CREATE TABLE user_sessions (
  id_session    BIGSERIAL PRIMARY KEY,
  id_user       BIGINT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  session_token VARCHAR(255) UNIQUE NOT NULL,
  refresh_token VARCHAR(255) UNIQUE,
  device_type   VARCHAR(30),           
  device_name   VARCHAR(100),
  browser       VARCHAR(100),
  os            VARCHAR(50),
  ip_address    INET,
  location      VARCHAR(100),
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  last_activity TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at    TIMESTAMP NOT NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT session_device_chk CHECK (
    device_type IS NULL OR
    device_type IN ('MOBILE','TABLET','DESKTOP','OTHER')
  )
);

CREATE INDEX idx_sessions_user   ON user_sessions(id_user);
CREATE INDEX idx_sessions_token  ON user_sessions(session_token);
CREATE INDEX idx_sessions_active ON user_sessions(id_user, is_active)
  WHERE is_active = TRUE;

-- 4. CALENDAR EVENTS
CREATE TABLE calendar_events (
  id_event      BIGSERIAL PRIMARY KEY,
  id_user       BIGINT REFERENCES users(id_user)           ON DELETE CASCADE,
  id_project    BIGINT REFERENCES projects(id_project)     ON DELETE CASCADE,
  id_Organization      BIGINT REFERENCES Organizations(id_Organization)         ON DELETE CASCADE,
  id_task       BIGINT REFERENCES tasks(id_task)           ON DELETE CASCADE,
  id_meeting    BIGINT REFERENCES meetings(id_meeting)     ON DELETE CASCADE,
  id_milestone  BIGINT REFERENCES milestones(id_milestone) ON DELETE CASCADE,

  title         VARCHAR(200) NOT NULL,
  description   TEXT,
  event_type    VARCHAR(30)  NOT NULL DEFAULT 'PERSONAL',
  color         VARCHAR(20),

  start_datetime TIMESTAMP NOT NULL,
  end_datetime   TIMESTAMP,
  all_day        BOOLEAN NOT NULL DEFAULT FALSE,

  is_recurring   BOOLEAN NOT NULL DEFAULT FALSE,
  recurrence_rule TEXT,               
  recurrence_end  TIMESTAMP,

  location       VARCHAR(200),
  reminder_min   INT[],               

  created_by     BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT cal_event_type_chk CHECK (
    event_type IN (
      'PERSONAL','TASK_DEADLINE','MILESTONE',
      'MEETING','SUBMISSION','EXAM',
      'HOLIDAY','OTHER'
    )
  ),
  CONSTRAINT cal_event_dates_chk CHECK (
    end_datetime IS NULL OR end_datetime >= start_datetime
  )
);

CREATE INDEX idx_cal_events_user    ON calendar_events(id_user);
CREATE INDEX idx_cal_events_project ON calendar_events(id_project);
CREATE INDEX idx_cal_events_dates   ON calendar_events(start_datetime, end_datetime);
CREATE INDEX idx_cal_events_type    ON calendar_events(event_type);

-- 5. ADMIN PANEL (Configs & Logs)
CREATE TABLE system_configs (
  id_config     BIGSERIAL PRIMARY KEY,
  config_key    VARCHAR(100) UNIQUE NOT NULL,
  config_value  TEXT NOT NULL,
  config_type   VARCHAR(20) NOT NULL DEFAULT 'STRING',
  description   TEXT,
  is_public     BOOLEAN NOT NULL DEFAULT FALSE,
  updated_by    BIGINT REFERENCES users(id_user) ON DELETE SET NULL,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT config_type_chk CHECK (
    config_type IN ('STRING','INTEGER','BOOLEAN','JSON','TEXT')
  )
);

CREATE TABLE admin_actions (
  id_action     BIGSERIAL PRIMARY KEY,
  id_admin      BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
  action_type   VARCHAR(50) NOT NULL,
  target_type   VARCHAR(50),
  target_id     BIGINT,
  description   TEXT,
  old_data      JSONB,
  new_data      JSONB,
  ip_address    INET,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT admin_action_type_chk CHECK (
    action_type IN (
      'USER_CREATE','USER_UPDATE','USER_DELETE',
      'USER_BLOCK','USER_UNBLOCK','USER_RESET_PASSWORD',
      'Organization_MANAGE','PROJECT_MANAGE',
      'ROLE_ASSIGN','CONFIG_UPDATE',
      'SYSTEM_MAINTENANCE'
    )
  )
);

CREATE INDEX idx_admin_actions_admin  ON admin_actions(id_admin);
CREATE INDEX idx_admin_actions_target ON admin_actions(target_type, target_id);
CREATE INDEX idx_admin_actions_date   ON admin_actions(created_at DESC);
CREATE INDEX idx_system_configs_key   ON system_configs(config_key);

-- 6. USER PROFILE
ALTER TABLE users
  ADD COLUMN cover_image      TEXT,
  ADD COLUMN social_github    VARCHAR(150),
  ADD COLUMN social_linkedin  VARCHAR(150),
  ADD COLUMN social_twitter   VARCHAR(150),
  ADD COLUMN website          TEXT,
  ADD COLUMN skills           TEXT[],
  ADD COLUMN interests        TEXT[],
  ADD COLUMN graduation_year  INT,
  ADD COLUMN is_supervisor    BOOLEAN NOT NULL DEFAULT FALSE;

CREATE TABLE user_stats (
  id_stat           BIGSERIAL PRIMARY KEY,
  id_user           BIGINT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  total_projects    INT NOT NULL DEFAULT 0,
  total_tasks_done  INT NOT NULL DEFAULT 0,
  total_Organizations      INT NOT NULL DEFAULT 0,
  total_submissions INT NOT NULL DEFAULT 0,
  avg_grade         DECIMAL(5,2),
  best_grade        DECIMAL(5,2),
  total_comments    INT NOT NULL DEFAULT 0,
  total_files       INT NOT NULL DEFAULT 0,
  streak_days       INT NOT NULL DEFAULT 0,
  last_active_date  DATE,
  updated_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT uq_user_stats UNIQUE (id_user),
  CONSTRAINT user_stats_grade_chk CHECK (
    (avg_grade IS NULL OR (avg_grade >= 0 AND avg_grade <= 20)) AND
    (best_grade IS NULL OR (best_grade >= 0 AND best_grade <= 20))
  )
);

CREATE INDEX idx_user_stats_user ON user_stats(id_user);

-- 7. RE-CREATE REPORTS WITH NEW CONSTRAINTS
DROP TABLE IF EXISTS reports CASCADE;
CREATE TABLE reports (
  id_report     BIGSERIAL PRIMARY KEY,
  id_user       BIGINT NOT NULL REFERENCES users(id_user)  ON DELETE CASCADE,
  id_project    BIGINT REFERENCES projects(id_project)     ON DELETE CASCADE,
  id_Organization      BIGINT REFERENCES Organizations(id_Organization)         ON DELETE CASCADE,
  report_name   VARCHAR(200) NOT NULL,
  report_type   VARCHAR(50)  NOT NULL,
  filters       JSONB,
  result_data   JSONB,
  file_url      TEXT,
  file_format   VARCHAR(10),           
  file_size     BIGINT,
  status        VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
  generated_at  TIMESTAMP,
  expires_at    TIMESTAMP,
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT reports_type_chk CHECK (
    report_type IN (
      'PROJECT_SUMMARY','TASK_REPORT',
      'PRODUCTIVITY','TIME_TRACKING',
      'MILESTONE_REPORT','MEMBER_ACTIVITY',
      'GRADE_REPORT','SUBMISSION_REPORT',
      'PEER_EVAL_REPORT','BURNDOWN_CHART',
      'Organization_STATS','COURSE_STATS'
    )
  ),
  CONSTRAINT reports_status_chk CHECK (
    status IN ('PENDING','PROCESSING','DONE','FAILED','EXPIRED')
  ),
  CONSTRAINT reports_format_chk CHECK (
    file_format IS NULL OR
    file_format IN ('PDF','XLSX','CSV','JSON')
  )
);

CREATE INDEX idx_reports_user    ON reports(id_user);
CREATE INDEX idx_reports_project ON reports(id_project);
CREATE INDEX idx_reports_type    ON reports(report_type);
CREATE INDEX idx_reports_status  ON reports(status);

-- 8. TRIGGERS
CREATE TRIGGER update_calendar_events_updated_at
  BEFORE UPDATE ON calendar_events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_system_configs_updated_at
  BEFORE UPDATE ON system_configs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_stats_updated_at
  BEFORE UPDATE ON user_stats
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE OR REPLACE FUNCTION update_user_stats_on_task()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'DONE' AND OLD.status <> 'DONE' THEN
    INSERT INTO user_stats (id_user, total_tasks_done)
    VALUES (NEW.assigned_to, 1)
    ON CONFLICT (id_user) DO UPDATE
    SET total_tasks_done = user_stats.total_tasks_done + 1,
        updated_at       = CURRENT_TIMESTAMP;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_user_stats_task
  AFTER UPDATE ON tasks
  FOR EACH ROW EXECUTE FUNCTION update_user_stats_on_task();

CREATE OR REPLACE FUNCTION update_user_stats_on_submission()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO user_stats (id_user, total_submissions)
    VALUES (NEW.submitted_by, 1)
    ON CONFLICT (id_user) DO UPDATE
    SET total_submissions = user_stats.total_submissions + 1,
        updated_at        = CURRENT_TIMESTAMP;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_user_stats_submission
  AFTER INSERT ON submissions
  FOR EACH ROW EXECUTE FUNCTION update_user_stats_on_submission();
