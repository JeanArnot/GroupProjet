-- V4__enterprise_schema.sql
-- 1. COMMENTS
DROP TABLE IF EXISTS comments CASCADE;

CREATE TABLE comments (
  id_comment        BIGSERIAL PRIMARY KEY,
  id_task           BIGINT NOT NULL REFERENCES tasks(id_task) ON DELETE CASCADE,
  id_user           BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
  parent_comment_id BIGINT REFERENCES comments(id_comment) ON DELETE CASCADE,
  comment_text      TEXT NOT NULL,
  is_edited         BOOLEAN NOT NULL DEFAULT FALSE,
  edited_at         TIMESTAMP,
  is_deleted        BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at        TIMESTAMP,
  created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT comment_self_ref_chk CHECK (
    parent_comment_id IS NULL OR 
    parent_comment_id <> id_comment
  )
);

CREATE TABLE comment_reactions (
  id_reaction  BIGSERIAL PRIMARY KEY,
  id_comment   BIGINT NOT NULL REFERENCES comments(id_comment) ON DELETE CASCADE,
  id_user      BIGINT NOT NULL REFERENCES users(id_user)       ON DELETE CASCADE,
  emoji        VARCHAR(10) NOT NULL,
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT uq_comment_reaction UNIQUE (id_comment, id_user, emoji),
  CONSTRAINT comment_reaction_emoji_chk CHECK (
    emoji IN ('👍','👎','❤️','🎉','😂','😮','😢','🔥','✅','❌')
  )
);

CREATE TABLE comment_mentions (
  id_mention   BIGSERIAL PRIMARY KEY,
  id_comment   BIGINT NOT NULL REFERENCES comments(id_comment) ON DELETE CASCADE,
  id_user      BIGINT NOT NULL REFERENCES users(id_user)       ON DELETE CASCADE,
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT uq_comment_mention UNIQUE (id_comment, id_user)
);

CREATE INDEX idx_comments_task       ON comments(id_task);
CREATE INDEX idx_comments_user       ON comments(id_user);
CREATE INDEX idx_comments_parent     ON comments(parent_comment_id);
CREATE INDEX idx_comment_reactions   ON comment_reactions(id_comment);
CREATE INDEX idx_comment_mentions    ON comment_mentions(id_comment);
CREATE INDEX idx_comment_mentions_u  ON comment_mentions(id_user);

-- 2. FILES
DROP TABLE IF EXISTS files CASCADE;

CREATE TABLE files (
  id_file       BIGSERIAL PRIMARY KEY,
  id_task       BIGINT REFERENCES tasks(id_task)       ON DELETE CASCADE,
  id_project    BIGINT REFERENCES projects(id_project) ON DELETE CASCADE,
  id_comment    BIGINT REFERENCES comments(id_comment) ON DELETE CASCADE,
  id_meeting    BIGINT REFERENCES meetings(id_meeting) ON DELETE CASCADE,
  id_message    BIGINT, 

  uploaded_by   BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
  file_name     VARCHAR(255) NOT NULL,
  original_name VARCHAR(255) NOT NULL,
  file_url      TEXT NOT NULL,
  thumbnail_url TEXT,
  file_size     BIGINT,
  file_type     VARCHAR(50),
  file_extension VARCHAR(20),
  
  storage_provider VARCHAR(30) DEFAULT 'LOCAL',
  storage_bucket   VARCHAR(150),
  storage_key      TEXT,
  
  is_public     BOOLEAN NOT NULL DEFAULT FALSE,
  access_token  VARCHAR(255),
  
  width         INT,
  height        INT,
  duration_sec  INT,
  checksum      VARCHAR(64),
  
  download_count INT NOT NULL DEFAULT 0,
  is_deleted    BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at    TIMESTAMP,

  uploaded_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT files_one_parent_chk CHECK (
    (id_task IS NOT NULL)::int +
    (id_project IS NOT NULL)::int +
    (id_comment IS NOT NULL)::int +
    (id_meeting IS NOT NULL)::int <= 1
  ),
  CONSTRAINT files_size_chk CHECK (file_size IS NULL OR file_size >= 0),
  CONSTRAINT files_storage_chk CHECK (
    storage_provider IN ('LOCAL','S3','GCS','AZURE','CLOUDINARY')
  )
);

CREATE INDEX idx_files_task      ON files(id_task);
CREATE INDEX idx_files_project   ON files(id_project);
CREATE INDEX idx_files_comment   ON files(id_comment);
CREATE INDEX idx_files_meeting   ON files(id_meeting);
CREATE INDEX idx_files_uploader  ON files(uploaded_by);

-- 3. TAGS / LABELS
CREATE TABLE tags (
  id_tag      BIGSERIAL PRIMARY KEY,
  id_Organization    BIGINT REFERENCES Organizations(id_Organization) ON DELETE CASCADE,
  tag_name    VARCHAR(50) NOT NULL,
  tag_color   VARCHAR(20) NOT NULL DEFAULT '#6366F1',
  tag_icon    VARCHAR(50),
  description TEXT,
  created_by  BIGINT REFERENCES users(id_user) ON DELETE SET NULL,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT uq_tag_Organization UNIQUE (tag_name, id_Organization)
);

CREATE TABLE task_tags (
  id_task    BIGINT NOT NULL REFERENCES tasks(id_task) ON DELETE CASCADE,
  id_tag     BIGINT NOT NULL REFERENCES tags(id_tag)   ON DELETE CASCADE,
  tagged_by  BIGINT REFERENCES users(id_user) ON DELETE SET NULL,
  tagged_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_task, id_tag)
);

CREATE TABLE project_tags (
  id_project BIGINT NOT NULL REFERENCES projects(id_project) ON DELETE CASCADE,
  id_tag     BIGINT NOT NULL REFERENCES tags(id_tag)         ON DELETE CASCADE,
  tagged_by  BIGINT REFERENCES users(id_user) ON DELETE SET NULL,
  tagged_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_project, id_tag)
);

CREATE INDEX idx_tags_Organization      ON tags(id_Organization);
CREATE INDEX idx_task_tags_task  ON task_tags(id_task);
CREATE INDEX idx_task_tags_tag   ON task_tags(id_tag);
CREATE INDEX idx_proj_tags_proj  ON project_tags(id_project);
CREATE INDEX idx_proj_tags_tag   ON project_tags(id_tag);

-- 4. INVITATIONS
CREATE TABLE invitations (
  id_invitation  BIGSERIAL PRIMARY KEY,
  id_Organization       BIGINT REFERENCES Organizations(id_Organization)     ON DELETE CASCADE,
  id_project     BIGINT REFERENCES projects(id_project) ON DELETE CASCADE,

  invited_by     BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
  invited_email  VARCHAR(150) NOT NULL,
  id_user        BIGINT REFERENCES users(id_user) ON DELETE CASCADE,

  role_to_assign VARCHAR(30) NOT NULL DEFAULT 'MEMBER',
  token          VARCHAR(255) UNIQUE NOT NULL,
  message        TEXT,

  status         VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  expires_at     TIMESTAMP NOT NULL,
  accepted_at    TIMESTAMP,
  declined_at    TIMESTAMP,
  decline_reason TEXT,

  sent_count     INT NOT NULL DEFAULT 1,
  last_sent_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT inv_target_chk CHECK (
    (id_Organization IS NOT NULL) OR (id_project IS NOT NULL)
  ),
  CONSTRAINT inv_status_chk CHECK (
    status IN ('PENDING','ACCEPTED','DECLINED','EXPIRED','CANCELLED')
  ),
  CONSTRAINT inv_role_chk CHECK (
    role_to_assign IN ('LEADER','MEMBER','VIEWER','REVIEWER')
  )
);

CREATE INDEX idx_invitations_email   ON invitations(invited_email);
CREATE INDEX idx_invitations_token   ON invitations(token);
CREATE INDEX idx_invitations_Organization   ON invitations(id_Organization);
CREATE INDEX idx_invitations_project ON invitations(id_project);
CREATE INDEX idx_invitations_status  ON invitations(status);

-- 5. TASK CHECKLISTS
CREATE TABLE task_checklists (
  id_checklist  BIGSERIAL PRIMARY KEY,
  id_task       BIGINT NOT NULL REFERENCES tasks(id_task) ON DELETE CASCADE,
  item_text     VARCHAR(500) NOT NULL,
  is_done       BOOLEAN NOT NULL DEFAULT FALSE,
  position      INT NOT NULL DEFAULT 0,
  
  assigned_to   BIGINT REFERENCES users(id_user) ON DELETE SET NULL,
  due_date      TIMESTAMP,
  completed_at  TIMESTAMP,
  completed_by  BIGINT REFERENCES users(id_user) ON DELETE SET NULL,

  created_by    BIGINT REFERENCES users(id_user) ON DELETE SET NULL,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_checklists_task ON task_checklists(id_task);
CREATE INDEX idx_checklists_user ON task_checklists(assigned_to);

-- 6. TIME TRACKING
CREATE TABLE time_logs (
  id_log        BIGSERIAL PRIMARY KEY,
  id_task       BIGINT NOT NULL REFERENCES tasks(id_task) ON DELETE CASCADE,
  id_user       BIGINT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  id_project    BIGINT REFERENCES projects(id_project)    ON DELETE CASCADE,

  started_at    TIMESTAMP NOT NULL,
  ended_at      TIMESTAMP,
  duration_min  INT,
  
  log_type      VARCHAR(20) NOT NULL DEFAULT 'MANUAL',
  note          TEXT,
  is_billable   BOOLEAN NOT NULL DEFAULT FALSE,
  hourly_rate   DECIMAL(10,2),

  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT time_log_dates_chk CHECK (
    ended_at IS NULL OR ended_at > started_at
  ),
  CONSTRAINT time_log_type_chk CHECK (
    log_type IN ('MANUAL','TIMER','IMPORTED')
  ),
  CONSTRAINT time_log_duration_chk CHECK (
    duration_min IS NULL OR duration_min > 0
  )
);

CREATE INDEX idx_time_logs_task    ON time_logs(id_task);
CREATE INDEX idx_time_logs_user    ON time_logs(id_user);
CREATE INDEX idx_time_logs_project ON time_logs(id_project);
CREATE INDEX idx_time_logs_dates   ON time_logs(started_at, ended_at);

-- 7. SPRINTS
CREATE TABLE sprints (
  id_sprint     BIGSERIAL PRIMARY KEY,
  id_project    BIGINT NOT NULL REFERENCES projects(id_project) ON DELETE CASCADE,
  sprint_name   VARCHAR(200) NOT NULL,
  sprint_goal   TEXT,
  sprint_number INT NOT NULL DEFAULT 1,

  status        VARCHAR(20) NOT NULL DEFAULT 'PLANNED',
  start_date    DATE NOT NULL,
  end_date      DATE NOT NULL,

  velocity      INT,
  capacity      INT,

  created_by    BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT sprints_dates_chk CHECK (end_date > start_date),
  CONSTRAINT sprints_status_chk CHECK (
    status IN ('PLANNED','ACTIVE','COMPLETED','CANCELLED')
  ),
  CONSTRAINT uq_sprint_number UNIQUE (id_project, sprint_number)
);

CREATE TABLE sprint_tasks (
  id_sprint  BIGINT NOT NULL REFERENCES sprints(id_sprint) ON DELETE CASCADE,
  id_task    BIGINT NOT NULL REFERENCES tasks(id_task)     ON DELETE CASCADE,
  
  story_points    INT DEFAULT 0,
  added_by        BIGINT REFERENCES users(id_user) ON DELETE SET NULL,
  added_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id_sprint, id_task)
);

CREATE INDEX idx_sprints_project    ON sprints(id_project);
CREATE INDEX idx_sprint_tasks_sprint ON sprint_tasks(id_sprint);
CREATE INDEX idx_sprint_tasks_task   ON sprint_tasks(id_task);

-- 8. CHAT / MESSAGING
CREATE TABLE channels (
  id_channel    BIGSERIAL PRIMARY KEY,
  id_Organization      BIGINT REFERENCES Organizations(id_Organization)     ON DELETE CASCADE,
  id_project    BIGINT REFERENCES projects(id_project) ON DELETE CASCADE,

  channel_name  VARCHAR(150) NOT NULL,
  description   TEXT,
  channel_type  VARCHAR(20) NOT NULL DEFAULT 'Organization',
  
  is_private    BOOLEAN NOT NULL DEFAULT FALSE,
  is_archived   BOOLEAN NOT NULL DEFAULT FALSE,
  is_readonly   BOOLEAN NOT NULL DEFAULT FALSE,

  created_by    BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT channels_type_chk CHECK (
    channel_type IN ('Organization','PROJECT','DIRECT','ANNOUNCEMENT')
  )
);

CREATE TABLE channel_members (
  id_channel_member BIGSERIAL PRIMARY KEY,
  id_channel    BIGINT NOT NULL REFERENCES channels(id_channel) ON DELETE CASCADE,
  id_user       BIGINT NOT NULL REFERENCES users(id_user)       ON DELETE CASCADE,
  
  role          VARCHAR(20) NOT NULL DEFAULT 'MEMBER',
  is_muted      BOOLEAN NOT NULL DEFAULT FALSE,
  last_read_at  TIMESTAMP,
  joined_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT uq_channel_member UNIQUE (id_channel, id_user),
  CONSTRAINT channel_member_role_chk CHECK (
    role IN ('OWNER','ADMIN','MEMBER','VIEWER')
  )
);

CREATE TABLE messages (
  id_message      BIGSERIAL PRIMARY KEY,
  id_channel      BIGINT NOT NULL REFERENCES channels(id_channel) ON DELETE CASCADE,
  id_user         BIGINT NOT NULL REFERENCES users(id_user)       ON DELETE RESTRICT,
  parent_message_id BIGINT REFERENCES messages(id_message) ON DELETE CASCADE,

  message_text    TEXT,
  message_type    VARCHAR(20) NOT NULL DEFAULT 'TEXT',
  
  id_task         BIGINT REFERENCES tasks(id_task)       ON DELETE SET NULL,
  id_project      BIGINT REFERENCES projects(id_project) ON DELETE SET NULL,

  is_edited       BOOLEAN NOT NULL DEFAULT FALSE,
  edited_at       TIMESTAMP,
  is_deleted      BOOLEAN NOT NULL DEFAULT FALSE,
  deleted_at      TIMESTAMP,
  is_pinned       BOOLEAN NOT NULL DEFAULT FALSE,
  pinned_by       BIGINT REFERENCES users(id_user) ON DELETE SET NULL,
  pinned_at       TIMESTAMP,

  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT messages_type_chk CHECK (
    message_type IN ('TEXT','FILE','IMAGE','SYSTEM','TASK_REF','PROJECT_REF')
  )
);

CREATE TABLE message_reactions (
  id_reaction  BIGSERIAL PRIMARY KEY,
  id_message   BIGINT NOT NULL REFERENCES messages(id_message) ON DELETE CASCADE,
  id_user      BIGINT NOT NULL REFERENCES users(id_user)       ON DELETE CASCADE,
  emoji        VARCHAR(10) NOT NULL,
  created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT uq_message_reaction UNIQUE (id_message, id_user, emoji)
);

CREATE TABLE message_reads (
  id_message  BIGINT NOT NULL REFERENCES messages(id_message) ON DELETE CASCADE,
  id_user     BIGINT NOT NULL REFERENCES users(id_user)       ON DELETE CASCADE,
  read_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_message, id_user)
);

CREATE INDEX idx_channels_Organization    ON channels(id_Organization);
CREATE INDEX idx_channels_project  ON channels(id_project);
CREATE INDEX idx_channel_members   ON channel_members(id_channel);
CREATE INDEX idx_channel_members_u ON channel_members(id_user);
CREATE INDEX idx_messages_channel  ON messages(id_channel);
CREATE INDEX idx_messages_user     ON messages(id_user);
CREATE INDEX idx_messages_parent   ON messages(parent_message_id);
CREATE INDEX idx_messages_created  ON messages(created_at DESC);
CREATE INDEX idx_message_reads     ON message_reads(id_user);

-- 9. AUDIT LOGS
CREATE TABLE audit_logs (
  id_audit      BIGSERIAL PRIMARY KEY,
  id_user       BIGINT REFERENCES users(id_user) ON DELETE SET NULL,
  
  entity_type   VARCHAR(50) NOT NULL,
  entity_id     BIGINT,
  
  action        VARCHAR(50) NOT NULL,
  
  old_values    JSONB,
  new_values    JSONB,
  changed_fields TEXT[],
  
  ip_address    INET,
  user_agent    TEXT,
  request_id    VARCHAR(100),
  session_id    VARCHAR(255),
  
  status        VARCHAR(20) NOT NULL DEFAULT 'SUCCESS',
  error_message TEXT,

  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT audit_action_chk CHECK (
    action IN (
      'CREATE','UPDATE','DELETE','VIEW',
      'LOGIN','LOGOUT','LOGIN_FAILED',
      'INVITE','JOIN','LEAVE','KICK',
      'UPLOAD','DOWNLOAD','EXPORT',
      'STATUS_CHANGE','ASSIGN','UNASSIGN',
      'COMMENT','REACT','MENTION',
      'ARCHIVE','RESTORE','BLOCK','UNBLOCK'
    )
  ),
  CONSTRAINT audit_entity_chk CHECK (
    entity_type IN (
      'USER','Organization','Organization_MEMBER',
      'PROJECT','PROJECT_MEMBER',
      'TASK','TASK_CHECKLIST','TASK_DEPENDENCY',
      'MILESTONE','SPRINT',
      'COMMENT','FILE','MESSAGE','CHANNEL',
      'MEETING','NOTIFICATION','INVITATION',
      'TIME_LOG','TAG'
    )
  ),
  CONSTRAINT audit_status_chk CHECK (
    status IN ('SUCCESS','FAILED','PARTIAL')
  )
);

CREATE INDEX idx_audit_user      ON audit_logs(id_user);
CREATE INDEX idx_audit_entity    ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_action    ON audit_logs(action);
CREATE INDEX idx_audit_created   ON audit_logs(created_at DESC);
CREATE INDEX idx_audit_ip        ON audit_logs(ip_address);

-- 10. USER SETTINGS
CREATE TABLE user_settings (
  id_setting       BIGSERIAL PRIMARY KEY,
  id_user          BIGINT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,

  notif_email           BOOLEAN NOT NULL DEFAULT TRUE,
  notif_push            BOOLEAN NOT NULL DEFAULT TRUE,
  notif_task_assigned   BOOLEAN NOT NULL DEFAULT TRUE,
  notif_task_due        BOOLEAN NOT NULL DEFAULT TRUE,
  notif_comment         BOOLEAN NOT NULL DEFAULT TRUE,
  notif_mention         BOOLEAN NOT NULL DEFAULT TRUE,
  notif_project_update  BOOLEAN NOT NULL DEFAULT TRUE,
  notif_meeting         BOOLEAN NOT NULL DEFAULT TRUE,
  notif_digest_daily    BOOLEAN NOT NULL DEFAULT FALSE,
  notif_digest_weekly   BOOLEAN NOT NULL DEFAULT TRUE,

  theme             VARCHAR(20) NOT NULL DEFAULT 'DARK',
  language          VARCHAR(10) NOT NULL DEFAULT 'fr',
  timezone          VARCHAR(50) NOT NULL DEFAULT 'UTC',
  date_format       VARCHAR(20) NOT NULL DEFAULT 'DD/MM/YYYY',
  time_format       VARCHAR(5)  NOT NULL DEFAULT '24H',
  
  default_view      VARCHAR(20) NOT NULL DEFAULT 'DASHBOARD',
  task_view         VARCHAR(20) NOT NULL DEFAULT 'KANBAN',
  items_per_page    INT         NOT NULL DEFAULT 20,
  
  profile_visibility VARCHAR(20) NOT NULL DEFAULT 'MEMBERS',
  show_online_status BOOLEAN    NOT NULL DEFAULT TRUE,
  show_last_seen     BOOLEAN    NOT NULL DEFAULT TRUE,

  updated_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT uq_user_settings    UNIQUE (id_user),
  CONSTRAINT settings_theme_chk  CHECK (theme IN ('DARK','LIGHT','SYSTEM')),
  CONSTRAINT settings_view_chk   CHECK (task_view IN ('KANBAN','LIST','CALENDAR','GANTT')),
  CONSTRAINT settings_privacy_chk CHECK (
    profile_visibility IN ('PUBLIC','MEMBERS','PRIVATE')
  )
);

CREATE INDEX idx_user_settings ON user_settings(id_user);

-- 11. NOTIFICATIONS
DROP TABLE IF EXISTS notifications CASCADE;

CREATE TABLE notifications (
  id_notification  BIGSERIAL PRIMARY KEY,
  id_user          BIGINT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,

  id_sender        BIGINT REFERENCES users(id_user) ON DELETE SET NULL,

  title            VARCHAR(200) NOT NULL,
  message          TEXT NOT NULL,
  notification_type VARCHAR(50) NOT NULL,

  entity_type      VARCHAR(50),
  entity_id        BIGINT,
  action_url       TEXT,

  is_read          BOOLEAN NOT NULL DEFAULT FALSE,
  read_at          TIMESTAMP,
  is_archived      BOOLEAN NOT NULL DEFAULT FALSE,
  archived_at      TIMESTAMP,

  sent_email       BOOLEAN NOT NULL DEFAULT FALSE,
  sent_push        BOOLEAN NOT NULL DEFAULT FALSE,
  email_sent_at    TIMESTAMP,
  push_sent_at     TIMESTAMP,

  priority         VARCHAR(10) NOT NULL DEFAULT 'NORMAL',

  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT notifications_type_chk CHECK (
    notification_type IN (
      'TASK_ASSIGNED','TASK_DUE','TASK_DONE',
      'TASK_COMMENT','TASK_MENTION','TASK_BLOCKED',
      'PROJECT_CREATED','PROJECT_UPDATED','PROJECT_COMPLETED',
      'Organization_INVITE','Organization_JOINED','Organization_LEFT',
      'MEETING_SCHEDULED','MEETING_REMINDER','MEETING_CANCELLED',
      'SPRINT_STARTED','SPRINT_ENDED',
      'MILESTONE_DUE','MILESTONE_DONE',
      'FILE_UPLOADED','FILE_SHARED',
      'MESSAGE_DIRECT','MESSAGE_MENTION',
      'INVITATION_RECEIVED','INVITATION_ACCEPTED',
      'SYSTEM_ALERT','SYSTEM_UPDATE'
    )
  ),
  CONSTRAINT notifications_priority_chk CHECK (
    priority IN ('LOW','NORMAL','HIGH','URGENT')
  )
);

CREATE INDEX idx_notif_user      ON notifications(id_user);
CREATE INDEX idx_notif_sender    ON notifications(id_sender);
CREATE INDEX idx_notif_unread    ON notifications(id_user, is_read) WHERE is_read = FALSE;
CREATE INDEX idx_notif_entity    ON notifications(entity_type, entity_id);
CREATE INDEX idx_notif_created   ON notifications(created_at DESC);

-- 12. WEBHOOKS
CREATE TABLE webhooks (
  id_webhook    BIGSERIAL PRIMARY KEY,
  id_Organization      BIGINT REFERENCES Organizations(id_Organization)     ON DELETE CASCADE,
  id_project    BIGINT REFERENCES projects(id_project) ON DELETE CASCADE,

  name          VARCHAR(150) NOT NULL,
  url           TEXT NOT NULL,
  secret        VARCHAR(255),
  
  events        TEXT[] NOT NULL,
  
  is_active     BOOLEAN NOT NULL DEFAULT TRUE,
  
  last_triggered_at  TIMESTAMP,
  success_count      INT NOT NULL DEFAULT 0,
  failure_count      INT NOT NULL DEFAULT 0,
  last_status_code   INT,
  last_response      TEXT,

  created_by    BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE webhook_deliveries (
  id_delivery   BIGSERIAL PRIMARY KEY,
  id_webhook    BIGINT NOT NULL REFERENCES webhooks(id_webhook) ON DELETE CASCADE,
  
  event_type    VARCHAR(100) NOT NULL,
  payload       JSONB NOT NULL,
  
  status_code   INT,
  response_body TEXT,
  duration_ms   INT,
  
  status        VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  attempt_count INT NOT NULL DEFAULT 0,
  next_retry_at TIMESTAMP,
  
  delivered_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT webhook_del_status_chk CHECK (
    status IN ('PENDING','SUCCESS','FAILED','RETRYING')
  )
);

CREATE INDEX idx_webhooks_Organization    ON webhooks(id_Organization);
CREATE INDEX idx_webhooks_project  ON webhooks(id_project);
CREATE INDEX idx_webhook_del       ON webhook_deliveries(id_webhook);
CREATE INDEX idx_webhook_del_status ON webhook_deliveries(status);

-- 13. REPORTS
CREATE TABLE reports (
  id_report     BIGSERIAL PRIMARY KEY,
  id_user       BIGINT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  id_project    BIGINT REFERENCES projects(id_project)    ON DELETE CASCADE,
  id_Organization      BIGINT REFERENCES Organizations(id_Organization)        ON DELETE CASCADE,

  report_name   VARCHAR(200) NOT NULL,
  report_type   VARCHAR(50) NOT NULL,
  
  filters       JSONB,
  result_data   JSONB,
  
  file_url      TEXT,
  file_size     BIGINT,
  
  status        VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  generated_at  TIMESTAMP,
  expires_at    TIMESTAMP,
  
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT reports_type_chk CHECK (
    report_type IN (
      'PROJECT_SUMMARY','TASK_REPORT',
      'PRODUCTIVITY','TIME_TRACKING',
      'SPRINT_REPORT','MILESTONE_REPORT',
      'MEMBER_ACTIVITY','BURNDOWN_CHART'
    )
  ),
  CONSTRAINT reports_status_chk CHECK (
    status IN ('PENDING','PROCESSING','DONE','FAILED','EXPIRED')
  )
);

CREATE INDEX idx_reports_user    ON reports(id_report);
CREATE INDEX idx_reports_project ON reports(id_project);
CREATE INDEX idx_reports_Organization   ON reports(id_Organization);

-- 14. TEMPLATES
CREATE TABLE project_templates (
  id_template   BIGSERIAL PRIMARY KEY,
  id_Organization      BIGINT REFERENCES Organizations(id_Organization) ON DELETE CASCADE,

  template_name VARCHAR(200) NOT NULL,
  description   TEXT,
  category      VARCHAR(50),
  template_data JSONB NOT NULL,
  
  is_public     BOOLEAN NOT NULL DEFAULT FALSE,
  use_count     INT NOT NULL DEFAULT 0,

  created_by    BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE task_templates (
  id_template   BIGSERIAL PRIMARY KEY,
  id_project    BIGINT REFERENCES projects(id_project) ON DELETE CASCADE,
  id_Organization      BIGINT REFERENCES Organizations(id_Organization)     ON DELETE CASCADE,

  template_name VARCHAR(200) NOT NULL,
  description   TEXT,
  template_data JSONB NOT NULL,

  is_public     BOOLEAN NOT NULL DEFAULT FALSE,
  use_count     INT NOT NULL DEFAULT 0,

  created_by    BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_proj_templates_Organization   ON project_templates(id_Organization);
CREATE INDEX idx_task_templates_project ON task_templates(id_project);

-- 15. TRIGGERS
CREATE TRIGGER update_comments_updated_at
  BEFORE UPDATE ON comments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_channels_updated_at
  BEFORE UPDATE ON channels
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_messages_updated_at
  BEFORE UPDATE ON messages
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sprints_updated_at
  BEFORE UPDATE ON sprints
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_time_logs_updated_at
  BEFORE UPDATE ON time_logs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_settings_updated_at
  BEFORE UPDATE ON user_settings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_webhooks_updated_at
  BEFORE UPDATE ON webhooks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_proj_templates_updated_at
  BEFORE UPDATE ON project_templates
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_task_templates_updated_at
  BEFORE UPDATE ON task_templates
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE OR REPLACE FUNCTION calculate_time_log_duration()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.ended_at IS NOT NULL AND NEW.started_at IS NOT NULL THEN
    NEW.duration_min = EXTRACT(
      EPOCH FROM (NEW.ended_at - NEW.started_at)
    )::INT / 60;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER calc_time_log_duration
  BEFORE INSERT OR UPDATE ON time_logs
  FOR EACH ROW EXECUTE FUNCTION calculate_time_log_duration();

CREATE OR REPLACE FUNCTION update_task_comment_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE tasks SET comment_count = comment_count + 1
    WHERE id_task = NEW.id_task;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE tasks SET comment_count = GREATEST(0, comment_count - 1)
    WHERE id_task = OLD.id_task;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_task_comment_count
  AFTER INSERT OR DELETE ON comments
  FOR EACH ROW EXECUTE FUNCTION update_task_comment_count();

CREATE OR REPLACE FUNCTION update_task_attachment_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.id_task IS NOT NULL THEN
    UPDATE tasks SET attachment_count = attachment_count + 1
    WHERE id_task = NEW.id_task;
  ELSIF TG_OP = 'DELETE' AND OLD.id_task IS NOT NULL THEN
    UPDATE tasks SET attachment_count = GREATEST(0, attachment_count - 1)
    WHERE id_task = OLD.id_task;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_task_attachment_count
  AFTER INSERT OR DELETE ON files
  FOR EACH ROW EXECUTE FUNCTION update_task_attachment_count();
