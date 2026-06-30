-- ============================================================
-- groupprojet - ACADEMIC PROJECT MANAGEMENT
-- Complete Database Schema
-- PostgreSQL - Enterprise Academic Edition
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DROP TABLE IF EXISTS reports CASCADE;
DROP TABLE IF EXISTS user_stats CASCADE;
DROP TABLE IF EXISTS admin_actions CASCADE;
DROP TABLE IF EXISTS system_configs CASCADE;
DROP TABLE IF EXISTS calendar_events CASCADE;
DROP TABLE IF EXISTS user_sessions CASCADE;
DROP TABLE IF EXISTS email_verifications CASCADE;
DROP TABLE IF EXISTS password_resets CASCADE;
DROP TABLE IF EXISTS task_templates CASCADE;
DROP TABLE IF EXISTS project_templates CASCADE;
DROP TABLE IF EXISTS user_productivity CASCADE;
DROP TABLE IF EXISTS user_settings CASCADE;
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS activities CASCADE;
DROP TABLE IF EXISTS task_history CASCADE;
DROP TABLE IF EXISTS time_logs CASCADE;
DROP TABLE IF EXISTS invitations CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS announcements CASCADE;
DROP TABLE IF EXISTS meeting_participants CASCADE;
DROP TABLE IF EXISTS meetings CASCADE;
DROP TABLE IF EXISTS files CASCADE;
DROP TABLE IF EXISTS comment_mentions CASCADE;
DROP TABLE IF EXISTS comment_reactions CASCADE;
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS peer_evaluations CASCADE;
DROP TABLE IF EXISTS submissions CASCADE;
DROP TABLE IF EXISTS milestones CASCADE;
DROP TABLE IF EXISTS task_checklists CASCADE;
DROP TABLE IF EXISTS task_dependencies CASCADE;
DROP TABLE IF EXISTS project_tags CASCADE;
DROP TABLE IF EXISTS task_tags CASCADE;
DROP TABLE IF EXISTS tags CASCADE;
DROP TABLE IF EXISTS tasks CASCADE;
DROP TABLE IF EXISTS project_members CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS Organization_members CASCADE;
DROP TABLE IF EXISTS Organizations CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS academic_years CASCADE;
DROP TABLE IF EXISTS supervisors CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS webhook_deliveries CASCADE;
DROP TABLE IF EXISTS webhooks CASCADE;
DROP TABLE IF EXISTS message_reads CASCADE;
DROP TABLE IF EXISTS message_reactions CASCADE;
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS channel_members CASCADE;
DROP TABLE IF EXISTS channels CASCADE;
DROP TABLE IF EXISTS sprint_tasks CASCADE;
DROP TABLE IF EXISTS sprints CASCADE;

-- ============================================================
-- 1. USERS
-- ============================================================
CREATE TABLE users (
  id_user         BIGSERIAL PRIMARY KEY,
  first_name      VARCHAR(100) NOT NULL,
  last_name       VARCHAR(100) NOT NULL,
  username        VARCHAR(100) UNIQUE NOT NULL,
  email           VARCHAR(150) UNIQUE NOT NULL,
  password        VARCHAR(255) NOT NULL,
  profile_image   TEXT,
  role            VARCHAR(20)  NOT NULL DEFAULT 'MEMBER',
  phone           VARCHAR(30),
  university      VARCHAR(150),
  speciality      VARCHAR(150),
  department      VARCHAR(150),
  student_id      VARCHAR(50),           -- Numéro étudiant
  academic_level  VARCHAR(30),           -- L1,L2,L3,M1,M2,PhD
  bio             TEXT,
  status          VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',
  last_login      TIMESTAMP,
  email_verified  BOOLEAN      NOT NULL DEFAULT FALSE,
  email_verified_at TIMESTAMP,
  created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT users_role_chk CHECK (
    role IN ('ADMIN','LEADER','MEMBER','SUPERVISOR')
  ),
  CONSTRAINT users_status_chk CHECK (
    status IN ('ACTIVE','INACTIVE','BLOCKED')
  ),
  CONSTRAINT users_level_chk CHECK (
    academic_level IS NULL OR
    academic_level IN ('L1','L2','L3','M1','M2','PhD','OTHER')
  )
);

-- ============================================================
-- 2. SUPERVISORS (Professeurs / Encadreurs)
-- ============================================================
CREATE TABLE supervisors (
  id_supervisor   BIGSERIAL PRIMARY KEY,
  id_user         BIGINT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  title           VARCHAR(50),           -- Dr., Prof., Mr., Mme.
  department      VARCHAR(150),
  university      VARCHAR(150),
  expertise       TEXT[],                -- Domaines d'expertise
  office          VARCHAR(100),
  office_hours    TEXT,
  website         TEXT,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT uq_supervisor_user UNIQUE (id_user),
  CONSTRAINT supervisors_title_chk CHECK (
    title IS NULL OR
    title IN ('Dr.','Prof.','Mr.','Mme.','Ing.','Assoc. Prof.')
  )
);

-- ============================================================
-- 3. ACADEMIC YEARS (Années académiques)
-- ============================================================
CREATE TABLE academic_years (
  id_academic_year BIGSERIAL PRIMARY KEY,
  year_label       VARCHAR(20) NOT NULL,  -- ex: '2024-2025'
  start_date       DATE        NOT NULL,
  end_date         DATE        NOT NULL,
  is_current       BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at       TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT uq_year_label    UNIQUE (year_label),
  CONSTRAINT academic_year_dates_chk CHECK (end_date > start_date)
);

-- ============================================================
-- 4. COURSES / MODULES (Matières)
-- ============================================================
CREATE TABLE courses (
  id_course        BIGSERIAL PRIMARY KEY,
  id_academic_year BIGINT REFERENCES academic_years(id_academic_year) ON DELETE SET NULL,
  course_name      VARCHAR(200) NOT NULL,
  course_code      VARCHAR(50)  UNIQUE,   -- ex: 'INF301'
  description      TEXT,
  credits          INT,
  coefficient      DECIMAL(4,2),
  university       VARCHAR(150),
  department       VARCHAR(150),
  academic_level   VARCHAR(30),
  semester         VARCHAR(20),
  is_active        BOOLEAN NOT NULL DEFAULT TRUE,
  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT courses_credits_chk CHECK (
    credits IS NULL OR credits > 0
  ),
  CONSTRAINT courses_semester_chk CHECK (
    semester IS NULL OR
    semester IN ('S1','S2','S3','S4','S5','S6','S7','S8','ANNUAL')
  ),
  CONSTRAINT courses_level_chk CHECK (
    academic_level IS NULL OR
    academic_level IN ('L1','L2','L3','M1','M2','PhD','OTHER')
  )
);

-- ============================================================
-- 5. OrganizationS
-- ============================================================
CREATE TABLE Organizations (
  id_Organization      BIGSERIAL PRIMARY KEY,
  Organization_name    VARCHAR(150) NOT NULL,
  description   TEXT,
  created_by    BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
  Organization_image   TEXT,
  access_code   VARCHAR(50) UNIQUE,
  visibility    VARCHAR(20) NOT NULL DEFAULT 'PRIVATE',
  status        VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  university    VARCHAR(150),
  department    VARCHAR(150),
  academic_year VARCHAR(20),
  max_members   INT,
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT Organizations_visibility_chk CHECK (
    visibility IN ('PRIVATE','PUBLIC')
  ),
  CONSTRAINT Organizations_status_chk CHECK (
    status IN ('ACTIVE','ARCHIVED')
  ),
  CONSTRAINT Organizations_max_members_chk CHECK (
    max_members IS NULL OR max_members > 0
  )
);

-- ============================================================
-- 6. Organization MEMBERS
-- ============================================================
CREATE TABLE Organization_members (
  id_Organization_member BIGSERIAL PRIMARY KEY,
  id_Organization        BIGINT NOT NULL REFERENCES Organizations(id_Organization) ON DELETE CASCADE,
  id_user         BIGINT NOT NULL REFERENCES users(id_user)   ON DELETE CASCADE,
  member_role     VARCHAR(20) NOT NULL DEFAULT 'MEMBER',
  joined_at       TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT uq_Organization_member UNIQUE (id_Organization, id_user),
  CONSTRAINT Organization_members_role_chk CHECK (
    member_role IN ('ADMIN','ENCADREUR','MEMBRE')
  )
);

-- ============================================================
-- 7. PROJECTS
-- ============================================================
CREATE TABLE projects (
  id_project         BIGSERIAL PRIMARY KEY,
  id_Organization           BIGINT NOT NULL REFERENCES Organizations(id_Organization)   ON DELETE CASCADE,
  id_course          BIGINT REFERENCES courses(id_course)          ON DELETE SET NULL,
  id_academic_year   BIGINT REFERENCES academic_years(id_academic_year) ON DELETE SET NULL,
  id_supervisor      BIGINT REFERENCES supervisors(id_supervisor)  ON DELETE SET NULL,

  project_name       VARCHAR(200) NOT NULL,
  description        TEXT,
  project_code       VARCHAR(50)  UNIQUE,
  objectives         TEXT,
  expected_outcomes  TEXT,

  -- Status & Priority
  status             VARCHAR(30)  NOT NULL DEFAULT 'PLANNING',
  priority           VARCHAR(20)  NOT NULL DEFAULT 'MEDIUM',
  health_status      VARCHAR(20)  NOT NULL DEFAULT 'GOOD',

  -- Progress
  progress           DECIMAL(5,2) NOT NULL DEFAULT 0,
  completed_tasks    INT          NOT NULL DEFAULT 0,
  total_tasks        INT          NOT NULL DEFAULT 0,

  -- Dates
  start_date         DATE,
  end_date           DATE,
  academic_deadline  DATE,          -- Date de rendu final
  estimated_hours    INT,

  -- Academic
  max_members        INT,
  project_type       VARCHAR(30)   NOT NULL DEFAULT 'ACADEMIC',
  submission_status  VARCHAR(30)   NOT NULL DEFAULT 'NOT_SUBMITTED',
  submitted_at       TIMESTAMP,

  -- Grading
  grade              DECIMAL(5,2),
  grade_comment      TEXT,
  graded_by          BIGINT REFERENCES users(id_user) ON DELETE SET NULL,
  graded_at          TIMESTAMP,

  -- Visual
  project_color      VARCHAR(20),
  project_image      TEXT,
  archived           BOOLEAN NOT NULL DEFAULT FALSE,

  created_by         BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
  created_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT projects_status_chk CHECK (
    status IN ('PLANNING','ACTIVE','ON_HOLD','COMPLETED','CANCELLED')
  ),
  CONSTRAINT projects_priority_chk CHECK (
    priority IN ('LOW','MEDIUM','HIGH','URGENT')
  ),
  CONSTRAINT projects_health_chk CHECK (
    health_status IN ('GOOD','WARNING','CRITICAL')
  ),
  CONSTRAINT projects_progress_chk CHECK (
    progress >= 0 AND progress <= 100
  ),
  CONSTRAINT projects_tasks_chk CHECK (
    completed_tasks >= 0 AND
    total_tasks     >= 0 AND
    completed_tasks <= total_tasks
  ),
  CONSTRAINT projects_hours_chk CHECK (
    estimated_hours IS NULL OR estimated_hours >= 0
  ),
  CONSTRAINT projects_grade_chk CHECK (
    grade IS NULL OR (grade >= 0 AND grade <= 20)
  ),
  CONSTRAINT projects_type_chk CHECK (
    project_type IN ('ACADEMIC','RESEARCH','INTERNSHIP','PERSONAL')
  ),
  CONSTRAINT projects_submission_chk CHECK (
    submission_status IN (
      'NOT_SUBMITTED','SUBMITTED',
      'UNDER_REVIEW','GRADED','REVISION_NEEDED'
    )
  ),
  CONSTRAINT projects_max_members_chk CHECK (
    max_members IS NULL OR max_members > 0
  )
);

-- ============================================================
-- 8. PROJECT MEMBERS
-- ============================================================
CREATE TABLE project_members (
  id_project_member BIGSERIAL PRIMARY KEY,
  id_project        BIGINT NOT NULL REFERENCES projects(id_project) ON DELETE CASCADE,
  id_user           BIGINT NOT NULL REFERENCES users(id_user)       ON DELETE CASCADE,
  role_in_project   VARCHAR(30) NOT NULL DEFAULT 'MEMBER',
  contribution_pct  DECIMAL(5,2),        -- % de contribution
  assigned_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT uq_project_member UNIQUE (id_project, id_user),
  CONSTRAINT project_members_role_chk CHECK (
    role_in_project IN ('CHEF_PROJET','MEMBRE')
  ),
  CONSTRAINT project_members_contribution_chk CHECK (
    contribution_pct IS NULL OR
    (contribution_pct >= 0 AND contribution_pct <= 100)
  )
);

-- ============================================================
-- 9. TAGS
-- ============================================================
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

-- ============================================================
-- 10. TASKS
-- ============================================================
CREATE TABLE tasks (
  id_task          BIGSERIAL PRIMARY KEY,
  id_project       BIGINT NOT NULL REFERENCES projects(id_project) ON DELETE CASCADE,
  assigned_to      BIGINT REFERENCES users(id_user) ON DELETE SET NULL,
  task_title       VARCHAR(200) NOT NULL,
  description      TEXT,
  task_code        VARCHAR(50)  UNIQUE,
  priority         VARCHAR(20)  NOT NULL DEFAULT 'MEDIUM',
  status           VARCHAR(20)  NOT NULL DEFAULT 'TODO',
  progress         DECIMAL(5,2) NOT NULL DEFAULT 0,
  estimated_time   INT,                  -- en minutes
  spent_time       INT          NOT NULL DEFAULT 0,
  start_date       TIMESTAMP,
  deadline         TIMESTAMP,
  completed_at     TIMESTAMP,
  is_blocked       BOOLEAN      NOT NULL DEFAULT FALSE,
  blocked_reason   TEXT,
  difficulty_level VARCHAR(20),
  story_points     INT          NOT NULL DEFAULT 0,
  reminder_sent    BOOLEAN      NOT NULL DEFAULT FALSE,
  attachment_count INT          NOT NULL DEFAULT 0,
  comment_count    INT          NOT NULL DEFAULT 0,
  created_by       BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
  created_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT tasks_status_chk CHECK (
    status IN ('TODO','IN_PROGRESS','REVIEW','DONE','CANCELLED')
  ),
  CONSTRAINT tasks_priority_chk CHECK (
    priority IN ('LOW','MEDIUM','HIGH','URGENT')
  ),
  CONSTRAINT tasks_progress_chk CHECK (
    progress >= 0 AND progress <= 100
  ),
  CONSTRAINT tasks_time_chk CHECK (
    spent_time >= 0 AND
    (estimated_time IS NULL OR estimated_time >= 0)
  ),
  CONSTRAINT tasks_diff_chk CHECK (
    difficulty_level IS NULL OR
    difficulty_level IN ('EASY','MEDIUM','HARD','EXPERT')
  ),
  CONSTRAINT tasks_story_points_chk CHECK (
    story_points >= 0
  )
);

-- ============================================================
-- 11. TASK TAGS
-- ============================================================
CREATE TABLE task_tags (
  id_task   BIGINT NOT NULL REFERENCES tasks(id_task) ON DELETE CASCADE,
  id_tag    BIGINT NOT NULL REFERENCES tags(id_tag)   ON DELETE CASCADE,
  tagged_by BIGINT REFERENCES users(id_user) ON DELETE SET NULL,
  tagged_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_task, id_tag)
);

-- ============================================================
-- 12. PROJECT TAGS
-- ============================================================
CREATE TABLE project_tags (
  id_project BIGINT NOT NULL REFERENCES projects(id_project) ON DELETE CASCADE,
  id_tag     BIGINT NOT NULL REFERENCES tags(id_tag)         ON DELETE CASCADE,
  tagged_by  BIGINT REFERENCES users(id_user) ON DELETE SET NULL,
  tagged_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_project, id_tag)
);

-- ============================================================
-- 13. TASK DEPENDENCIES
-- ============================================================
CREATE TABLE task_dependencies (
  id_dependency      BIGSERIAL PRIMARY KEY,
  task_id            BIGINT NOT NULL REFERENCES tasks(id_task) ON DELETE CASCADE,
  depends_on_task_id BIGINT NOT NULL REFERENCES tasks(id_task) ON DELETE CASCADE,
  dependency_type    VARCHAR(20) NOT NULL DEFAULT 'FINISH_TO_START',

  CONSTRAINT uq_task_dependency UNIQUE (task_id, depends_on_task_id),
  CONSTRAINT task_dependency_self_chk CHECK (
    task_id <> depends_on_task_id
  ),
  CONSTRAINT task_dep_type_chk CHECK (
    dependency_type IN (
      'FINISH_TO_START',
      'START_TO_START',
      'FINISH_TO_FINISH',
      'START_TO_FINISH'
    )
  )
);

-- ============================================================
-- 14. TASK CHECKLISTS
-- ============================================================
CREATE TABLE task_checklists (
  id_checklist  BIGSERIAL PRIMARY KEY,
  id_task       BIGINT NOT NULL REFERENCES tasks(id_task) ON DELETE CASCADE,
  item_text     VARCHAR(500) NOT NULL,
  is_done       BOOLEAN      NOT NULL DEFAULT FALSE,
  position      INT          NOT NULL DEFAULT 0,
  assigned_to   BIGINT REFERENCES users(id_user) ON DELETE SET NULL,
  due_date      TIMESTAMP,
  completed_at  TIMESTAMP,
  completed_by  BIGINT REFERENCES users(id_user) ON DELETE SET NULL,
  created_by    BIGINT REFERENCES users(id_user) ON DELETE SET NULL,
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 15. MILESTONES (Jalons)
-- ============================================================
CREATE TABLE milestones (
  id_milestone          BIGSERIAL PRIMARY KEY,
  id_project            BIGINT NOT NULL REFERENCES projects(id_project) ON DELETE CASCADE,
  milestone_name        VARCHAR(200) NOT NULL,
  description           TEXT,
  due_date              DATE,
  status                VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
  completion_percentage DECIMAL(5,2) NOT NULL DEFAULT 0,
  is_submission_point   BOOLEAN      NOT NULL DEFAULT FALSE,
  grade                 DECIMAL(5,2),
  grade_comment         TEXT,
  graded_by             BIGINT REFERENCES users(id_user) ON DELETE SET NULL,
  graded_at             TIMESTAMP,
  created_by            BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
  created_at            TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at            TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT milestones_status_chk CHECK (
    status IN ('PENDING','IN_PROGRESS','DONE','OVERDUE','CANCELLED')
  ),
  CONSTRAINT milestones_completion_chk CHECK (
    completion_percentage >= 0 AND
    completion_percentage <= 100
  ),
  CONSTRAINT milestones_grade_chk CHECK (
    grade IS NULL OR (grade >= 0 AND grade <= 20)
  )
);

-- ============================================================
-- 16. SUBMISSIONS (Soumissions des travaux)
-- ============================================================
CREATE TABLE submissions (
  id_submission    BIGSERIAL PRIMARY KEY,
  id_project       BIGINT NOT NULL REFERENCES projects(id_project) ON DELETE CASCADE,
  id_task          BIGINT REFERENCES tasks(id_task)                ON DELETE CASCADE,
  id_milestone     BIGINT REFERENCES milestones(id_milestone)      ON DELETE CASCADE,
  submitted_by     BIGINT NOT NULL REFERENCES users(id_user)       ON DELETE RESTRICT,
  submission_title VARCHAR(200) NOT NULL,
  submission_note  TEXT,
  file_urls        TEXT[],
  status           VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
  grade            DECIMAL(5,2),
  feedback         TEXT,
  evaluated_by     BIGINT REFERENCES users(id_user) ON DELETE SET NULL,
  evaluated_at     TIMESTAMP,
  due_date         TIMESTAMP,
  submitted_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  is_late          BOOLEAN      NOT NULL DEFAULT FALSE,
  late_hours       INT,
  attempt_number   INT          NOT NULL DEFAULT 1,

  CONSTRAINT submissions_status_chk CHECK (
    status IN (
      'PENDING','UNDER_REVIEW',
      'APPROVED','REJECTED','REVISION_NEEDED'
    )
  ),
  CONSTRAINT submissions_grade_chk CHECK (
    grade IS NULL OR (grade >= 0 AND grade <= 20)
  ),
  CONSTRAINT submissions_attempt_chk CHECK (
    attempt_number >= 1
  )
);

-- ============================================================
-- 17. PEER EVALUATIONS (Évaluation entre membres)
-- ============================================================
CREATE TABLE peer_evaluations (
  id_evaluation        BIGSERIAL PRIMARY KEY,
  id_project           BIGINT NOT NULL REFERENCES projects(id_project) ON DELETE CASCADE,
  evaluator_id         BIGINT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  evaluated_id         BIGINT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  score_participation  INT,
  score_communication  INT,
  score_quality        INT,
  score_punctuality    INT,
  score_teamwork       INT,
  overall_score        DECIMAL(4,2),
  comment              TEXT,
  is_anonymous         BOOLEAN   NOT NULL DEFAULT TRUE,
  created_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT uq_peer_eval UNIQUE (id_project, evaluator_id, evaluated_id),
  CONSTRAINT peer_eval_self_chk CHECK (
    evaluator_id <> evaluated_id
  ),
  CONSTRAINT peer_eval_participation_chk CHECK (
    score_participation IS NULL OR
    score_participation BETWEEN 0 AND 5
  ),
  CONSTRAINT peer_eval_communication_chk CHECK (
    score_communication IS NULL OR
    score_communication BETWEEN 0 AND 5
  ),
  CONSTRAINT peer_eval_quality_chk CHECK (
    score_quality IS NULL OR
    score_quality BETWEEN 0 AND 5
  ),
  CONSTRAINT peer_eval_punctuality_chk CHECK (
    score_punctuality IS NULL OR
    score_punctuality BETWEEN 0 AND 5
  ),
  CONSTRAINT peer_eval_teamwork_chk CHECK (
    score_teamwork IS NULL OR
    score_teamwork BETWEEN 0 AND 5
  ),
  CONSTRAINT peer_eval_overall_chk CHECK (
    overall_score IS NULL OR
    (overall_score >= 0 AND overall_score <= 5)
  )
);

-- ============================================================
-- 18. COMMENTS
-- ============================================================
CREATE TABLE comments (
  id_comment        BIGSERIAL PRIMARY KEY,
  id_task           BIGINT NOT NULL REFERENCES tasks(id_task) ON DELETE CASCADE,
  id_user           BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
  parent_comment_id BIGINT REFERENCES comments(id_comment)   ON DELETE CASCADE,
  comment_text      TEXT NOT NULL,
  is_edited         BOOLEAN   NOT NULL DEFAULT FALSE,
  edited_at         TIMESTAMP,
  is_deleted        BOOLEAN   NOT NULL DEFAULT FALSE,
  deleted_at        TIMESTAMP,
  created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT comment_self_ref_chk CHECK (
    parent_comment_id IS NULL OR
    parent_comment_id <> id_comment
  )
);

-- ============================================================
-- 19. COMMENT REACTIONS
-- ============================================================
CREATE TABLE comment_reactions (
  id_reaction BIGSERIAL PRIMARY KEY,
  id_comment  BIGINT NOT NULL REFERENCES comments(id_comment) ON DELETE CASCADE,
  id_user     BIGINT NOT NULL REFERENCES users(id_user)       ON DELETE CASCADE,
  emoji       VARCHAR(10) NOT NULL,
  created_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT uq_comment_reaction UNIQUE (id_comment, id_user, emoji),
  CONSTRAINT comment_reaction_emoji_chk CHECK (
    emoji IN ('👍','👎','❤️','🎉','😂','😮','😢','🔥','✅','❌')
  )
);

-- ============================================================
-- 20. COMMENT MENTIONS
-- ============================================================
CREATE TABLE comment_mentions (
  id_mention  BIGSERIAL PRIMARY KEY,
  id_comment  BIGINT NOT NULL REFERENCES comments(id_comment) ON DELETE CASCADE,
  id_user     BIGINT NOT NULL REFERENCES users(id_user)       ON DELETE CASCADE,
  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT uq_comment_mention UNIQUE (id_comment, id_user)
);

-- ============================================================
-- 22. MEETINGS
-- ============================================================
CREATE TABLE meetings (
  id_meeting       BIGSERIAL PRIMARY KEY,
  id_project       BIGINT NOT NULL REFERENCES projects(id_project) ON DELETE CASCADE,
  title            VARCHAR(200) NOT NULL,
  description      TEXT,
  meeting_link     TEXT,
  meeting_type     VARCHAR(20)  NOT NULL DEFAULT 'TEAM',
  meeting_date     TIMESTAMP    NOT NULL,
  duration_minutes INT,
  location         VARCHAR(200),
  agenda           TEXT,
  minutes          TEXT,          -- Compte-rendu
  status           VARCHAR(20)   NOT NULL DEFAULT 'SCHEDULED',
  created_by       BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
  created_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT meetings_duration_chk CHECK (
    duration_minutes IS NULL OR duration_minutes > 0
  ),
  CONSTRAINT meetings_type_chk CHECK (
    meeting_type IN ('TEAM','SUPERVISOR','REVIEW','DEFENCE')
  ),
  CONSTRAINT meetings_status_chk CHECK (
    status IN ('SCHEDULED','IN_PROGRESS','DONE','CANCELLED','POSTPONED')
  )
);

-- ============================================================
-- 23. MEETING PARTICIPANTS
-- ============================================================
CREATE TABLE meeting_participants (
  id_participant    BIGSERIAL PRIMARY KEY,
  id_meeting        BIGINT NOT NULL REFERENCES meetings(id_meeting) ON DELETE CASCADE,
  id_user           BIGINT NOT NULL REFERENCES users(id_user)       ON DELETE CASCADE,
  attendance_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  joined_at         TIMESTAMP,
  left_at           TIMESTAMP,
  note              TEXT,

  CONSTRAINT uq_meeting_participant UNIQUE (id_meeting, id_user),
  CONSTRAINT meeting_participants_status_chk CHECK (
    attendance_status IN ('PENDING','PRESENT','ABSENT','LATE','EXCUSED')
  )
);

-- ============================================================
-- 24. ANNOUNCEMENTS (Annonces)
-- ============================================================
CREATE TABLE announcements (
  id_announcement BIGSERIAL PRIMARY KEY,
  id_project      BIGINT REFERENCES projects(id_project) ON DELETE CASCADE,
  id_Organization        BIGINT REFERENCES Organizations(id_Organization)     ON DELETE CASCADE,
  id_course       BIGINT REFERENCES courses(id_course)   ON DELETE CASCADE,
  created_by      BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
  title           VARCHAR(200) NOT NULL,
  content         TEXT         NOT NULL,
  priority        VARCHAR(20)  NOT NULL DEFAULT 'NORMAL',
  is_pinned       BOOLEAN      NOT NULL DEFAULT FALSE,
  is_published    BOOLEAN      NOT NULL DEFAULT TRUE,
  expires_at      TIMESTAMP,
  created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT announce_priority_chk CHECK (
    priority IN ('LOW','NORMAL','HIGH','URGENT')
  )
);

-- ============================================================
-- 25. NOTIFICATIONS
-- ============================================================
CREATE TABLE notifications (
  id_notification   BIGSERIAL PRIMARY KEY,
  id_user           BIGINT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  id_sender         BIGINT REFERENCES users(id_user)          ON DELETE SET NULL,
  title             VARCHAR(200) NOT NULL,
  message           TEXT         NOT NULL,
  notification_type VARCHAR(60)  NOT NULL,
  entity_type       VARCHAR(50),
  entity_id         BIGINT,
  action_url        TEXT,
  is_read           BOOLEAN      NOT NULL DEFAULT FALSE,
  read_at           TIMESTAMP,
  is_archived       BOOLEAN      NOT NULL DEFAULT FALSE,
  archived_at       TIMESTAMP,
  sent_email        BOOLEAN      NOT NULL DEFAULT FALSE,
  sent_push         BOOLEAN      NOT NULL DEFAULT FALSE,
  email_sent_at     TIMESTAMP,
  push_sent_at      TIMESTAMP,
  priority          VARCHAR(10)  NOT NULL DEFAULT 'NORMAL',
  created_at        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT notifications_type_chk CHECK (
    notification_type IN (
      'TASK_ASSIGNED','TASK_DUE','TASK_DONE',
      'TASK_COMMENT','TASK_MENTION','TASK_BLOCKED',
      'PROJECT_CREATED','PROJECT_UPDATED','PROJECT_COMPLETED',
      'Organization_INVITE','Organization_JOINED','Organization_LEFT',
      'MEETING_SCHEDULED','MEETING_REMINDER','MEETING_CANCELLED',
      'MILESTONE_DUE','MILESTONE_DONE',
      'SUBMISSION_RECEIVED','SUBMISSION_GRADED',
      'PEER_EVAL_REQUEST','PEER_EVAL_DONE',
      'ANNOUNCEMENT_NEW','ANNOUNCEMENT_UPDATED',
      'FILE_UPLOADED','FILE_SHARED',
      'INVITATION_RECEIVED','INVITATION_ACCEPTED',
      'GRADE_PUBLISHED','FEEDBACK_RECEIVED',
      'SYSTEM_ALERT','SYSTEM_UPDATE'
    )
  ),
  CONSTRAINT notifications_priority_chk CHECK (
    priority IN ('LOW','NORMAL','HIGH','URGENT')
  )
);

-- ============================================================
-- 26. INVITATIONS
-- ============================================================
CREATE TABLE invitations (
  id_invitation  BIGSERIAL PRIMARY KEY,
  id_Organization       BIGINT REFERENCES Organizations(id_Organization)     ON DELETE CASCADE,
  id_project     BIGINT REFERENCES projects(id_project) ON DELETE CASCADE,
  invited_by     BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
  invited_email  VARCHAR(150) NOT NULL,
  id_user        BIGINT REFERENCES users(id_user) ON DELETE CASCADE,
  role_to_assign VARCHAR(30)  NOT NULL DEFAULT 'MEMBER',
  token          VARCHAR(255) UNIQUE NOT NULL,
  message        TEXT,
  status         VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
  expires_at     TIMESTAMP    NOT NULL,
  accepted_at    TIMESTAMP,
  declined_at    TIMESTAMP,
  decline_reason TEXT,
  sent_count     INT          NOT NULL DEFAULT 1,
  last_sent_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

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

-- ============================================================
-- 27. TIME LOGS
-- ============================================================
CREATE TABLE time_logs (
  id_log       BIGSERIAL PRIMARY KEY,
  id_task      BIGINT NOT NULL REFERENCES tasks(id_task)    ON DELETE CASCADE,
  id_user      BIGINT NOT NULL REFERENCES users(id_user)    ON DELETE CASCADE,
  id_project   BIGINT REFERENCES projects(id_project)       ON DELETE CASCADE,
  started_at   TIMESTAMP    NOT NULL,
  ended_at     TIMESTAMP,
  duration_min INT,
  log_type     VARCHAR(20)  NOT NULL DEFAULT 'MANUAL',
  note         TEXT,
  created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

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

-- ============================================================
-- 28. TASK HISTORY
-- ============================================================
CREATE TABLE task_history (
  id_history         BIGSERIAL PRIMARY KEY,
  id_task            BIGINT NOT NULL REFERENCES tasks(id_task) ON DELETE CASCADE,
  changed_by         BIGINT REFERENCES users(id_user)          ON DELETE SET NULL,
  field_changed      VARCHAR(50),
  old_value          TEXT,
  new_value          TEXT,
  old_status         VARCHAR(20),
  new_status         VARCHAR(20),
  change_description TEXT,
  changed_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 29. ACTIVITIES
-- ============================================================
CREATE TABLE activities (
  id_activity    BIGSERIAL PRIMARY KEY,
  id_user        BIGINT REFERENCES users(id_user)       ON DELETE SET NULL,
  id_project     BIGINT REFERENCES projects(id_project) ON DELETE CASCADE,
  id_Organization       BIGINT REFERENCES Organizations(id_Organization)     ON DELETE CASCADE,
  activity_type  VARCHAR(100) NOT NULL,
  entity_type    VARCHAR(50),
  entity_id      BIGINT,
  description    TEXT,
  metadata       JSONB,
  created_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 30. AUDIT LOGS
-- ============================================================
CREATE TABLE audit_logs (
  id_audit       BIGSERIAL PRIMARY KEY,
  id_user        BIGINT REFERENCES users(id_user) ON DELETE SET NULL,
  entity_type    VARCHAR(50)  NOT NULL,
  entity_id      BIGINT,
  action         VARCHAR(50)  NOT NULL,
  old_values     JSONB,
  new_values     JSONB,
  changed_fields TEXT[],
  ip_address     INET,
  user_agent     TEXT,
  request_id     VARCHAR(100),
  status         VARCHAR(20)  NOT NULL DEFAULT 'SUCCESS',
  error_message  TEXT,
  created_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT audit_status_chk CHECK (
    status IN ('SUCCESS','FAILED','PARTIAL')
  )
);

-- ============================================================
-- 31. USER SETTINGS
-- ============================================================
CREATE TABLE user_settings (
  id_setting             BIGSERIAL PRIMARY KEY,
  id_user                BIGINT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  notif_email            BOOLEAN NOT NULL DEFAULT TRUE,
  notif_push             BOOLEAN NOT NULL DEFAULT TRUE,
  notif_task_assigned    BOOLEAN NOT NULL DEFAULT TRUE,
  notif_task_due         BOOLEAN NOT NULL DEFAULT TRUE,
  notif_comment          BOOLEAN NOT NULL DEFAULT TRUE,
  notif_mention          BOOLEAN NOT NULL DEFAULT TRUE,
  notif_project_update   BOOLEAN NOT NULL DEFAULT TRUE,
  notif_meeting          BOOLEAN NOT NULL DEFAULT TRUE,
  notif_submission       BOOLEAN NOT NULL DEFAULT TRUE,
  notif_grade            BOOLEAN NOT NULL DEFAULT TRUE,
  notif_peer_eval        BOOLEAN NOT NULL DEFAULT TRUE,
  notif_announcement     BOOLEAN NOT NULL DEFAULT TRUE,
  notif_digest_daily     BOOLEAN NOT NULL DEFAULT FALSE,
  notif_digest_weekly    BOOLEAN NOT NULL DEFAULT TRUE,
  theme                  VARCHAR(20) NOT NULL DEFAULT 'DARK',
  language               VARCHAR(10) NOT NULL DEFAULT 'fr',
  timezone               VARCHAR(50) NOT NULL DEFAULT 'UTC',
  date_format            VARCHAR(20) NOT NULL DEFAULT 'DD/MM/YYYY',
  time_format            VARCHAR(5)  NOT NULL DEFAULT '24H',
  default_view           VARCHAR(20) NOT NULL DEFAULT 'DASHBOARD',
  task_view              VARCHAR(20) NOT NULL DEFAULT 'KANBAN',
  items_per_page         INT         NOT NULL DEFAULT 20,
  profile_visibility     VARCHAR(20) NOT NULL DEFAULT 'MEMBERS',
  show_online_status     BOOLEAN     NOT NULL DEFAULT TRUE,
  show_last_seen         BOOLEAN     NOT NULL DEFAULT TRUE,
  updated_at             TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT uq_user_settings     UNIQUE (id_user),
  CONSTRAINT settings_theme_chk   CHECK (theme IN ('DARK','LIGHT','SYSTEM')),
  CONSTRAINT settings_view_chk    CHECK (task_view IN ('KANBAN','LIST','CALENDAR','GANTT')),
  CONSTRAINT settings_privacy_chk CHECK (
    profile_visibility IN ('PUBLIC','MEMBERS','PRIVATE')
  )
);

-- ============================================================
-- 32. USER PRODUCTIVITY
-- ============================================================
CREATE TABLE user_productivity (
  id_productivity    BIGSERIAL PRIMARY KEY,
  id_user            BIGINT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  completed_tasks    INT          NOT NULL DEFAULT 0,
  late_tasks         INT          NOT NULL DEFAULT 0,
  total_hours_worked INT          NOT NULL DEFAULT 0,
  productivity_score DECIMAL(5,2) NOT NULL DEFAULT 0,
  tasks_on_time      INT          NOT NULL DEFAULT 0,
  tasks_late         INT          NOT NULL DEFAULT 0,
  avg_task_duration  DECIMAL(8,2),
  submissions_count  INT          NOT NULL DEFAULT 0,
  avg_grade          DECIMAL(5,2),
  updated_at         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT uq_user_productivity UNIQUE (id_user),
  CONSTRAINT user_productivity_chk CHECK (
    completed_tasks    >= 0 AND
    late_tasks         >= 0 AND
    total_hours_worked >= 0 AND
    productivity_score >= 0 AND
    productivity_score <= 100 AND
    tasks_on_time      >= 0 AND
    tasks_late         >= 0 AND
    submissions_count  >= 0
  ),
  CONSTRAINT user_productivity_grade_chk CHECK (
    avg_grade IS NULL OR (avg_grade >= 0 AND avg_grade <= 20)
  )
);

-- ============================================================
-- 33. PROJECT TEMPLATES
-- ============================================================
CREATE TABLE project_templates (
  id_template   BIGSERIAL PRIMARY KEY,
  id_Organization      BIGINT REFERENCES Organizations(id_Organization)   ON DELETE CASCADE,
  id_course     BIGINT REFERENCES courses(id_course) ON DELETE SET NULL,
  template_name VARCHAR(200) NOT NULL,
  description   TEXT,
  category      VARCHAR(50),
  template_data JSONB        NOT NULL,
  is_public     BOOLEAN      NOT NULL DEFAULT FALSE,
  use_count     INT          NOT NULL DEFAULT 0,
  created_by    BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 34. TASK TEMPLATES
-- ============================================================
CREATE TABLE task_templates (
  id_template   BIGSERIAL PRIMARY KEY,
  id_project    BIGINT REFERENCES projects(id_project) ON DELETE CASCADE,
  id_Organization      BIGINT REFERENCES Organizations(id_Organization)     ON DELETE CASCADE,
  template_name VARCHAR(200) NOT NULL,
  description   TEXT,
  template_data JSONB        NOT NULL,
  is_public     BOOLEAN      NOT NULL DEFAULT FALSE,
  use_count     INT          NOT NULL DEFAULT 0,
  created_by    BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 35. FILES
-- ============================================================
CREATE TABLE files (
  id_file           BIGSERIAL PRIMARY KEY,
  id_task           BIGINT REFERENCES tasks(id_task)           ON DELETE CASCADE,
  id_project        BIGINT REFERENCES projects(id_project)     ON DELETE CASCADE,
  id_comment        BIGINT REFERENCES comments(id_comment)     ON DELETE CASCADE,
  id_meeting        BIGINT REFERENCES meetings(id_meeting)     ON DELETE CASCADE,
  id_submission     BIGINT REFERENCES submissions(id_submission) ON DELETE CASCADE,
  id_announcement   BIGINT REFERENCES announcements(id_announcement) ON DELETE CASCADE,
  uploaded_by       BIGINT NOT NULL REFERENCES users(id_user)  ON DELETE RESTRICT,
  file_name         VARCHAR(255) NOT NULL,
  original_name     VARCHAR(255) NOT NULL,
  file_url          TEXT         NOT NULL,
  thumbnail_url     TEXT,
  file_size         BIGINT,
  file_type         VARCHAR(50),
  file_extension    VARCHAR(20),
  storage_provider  VARCHAR(30)  NOT NULL DEFAULT 'LOCAL',
  storage_bucket    VARCHAR(150),
  storage_key       TEXT,
  is_public         BOOLEAN      NOT NULL DEFAULT FALSE,
  checksum          VARCHAR(64),
  download_count    INT          NOT NULL DEFAULT 0,
  is_deleted        BOOLEAN      NOT NULL DEFAULT FALSE,
  deleted_at        TIMESTAMP,
  uploaded_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT files_size_chk CHECK (
    file_size IS NULL OR file_size >= 0
  ),
  CONSTRAINT files_storage_chk CHECK (
    storage_provider IN ('LOCAL','S3','GCS','AZURE','CLOUDINARY')
  ),
  CONSTRAINT files_one_parent_chk CHECK (
    (id_task IS NOT NULL)::int +
    (id_project IS NOT NULL)::int +
    (id_comment IS NOT NULL)::int +
    (id_meeting IS NOT NULL)::int +
    (id_submission IS NOT NULL)::int +
    (id_announcement IS NOT NULL)::int <= 1
  )
);

-- ============================================================
-- ALL INDEXES
-- ============================================================

-- Users
CREATE INDEX idx_users_email        ON users(email);
CREATE INDEX idx_users_username     ON users(username);
CREATE INDEX idx_users_university   ON users(university);
CREATE INDEX idx_users_status       ON users(status);
CREATE INDEX idx_users_role         ON users(role);

-- Supervisors
CREATE INDEX idx_supervisors_user   ON supervisors(id_user);

-- Courses
CREATE INDEX idx_courses_year       ON courses(id_academic_year);
CREATE INDEX idx_courses_code       ON courses(course_code);

-- Organizations
CREATE INDEX idx_Organizations_created_by  ON Organizations(created_by);
CREATE INDEX idx_Organizations_status      ON Organizations(status);

-- Organization Members
CREATE INDEX idx_Organization_members_Organization ON Organization_members(id_Organization);
CREATE INDEX idx_Organization_members_user  ON Organization_members(id_user);

-- Projects
CREATE INDEX idx_projects_Organization      ON projects(id_Organization);
CREATE INDEX idx_projects_course     ON projects(id_course);
CREATE INDEX idx_projects_supervisor ON projects(id_supervisor);
CREATE INDEX idx_projects_year       ON projects(id_academic_year);
CREATE INDEX idx_projects_status     ON projects(status);
CREATE INDEX idx_projects_created_by ON projects(created_by);

-- Project Members
CREATE INDEX idx_proj_members_project ON project_members(id_project);
CREATE INDEX idx_proj_members_user    ON project_members(id_user);

-- Tags
CREATE INDEX idx_tags_Organization          ON tags(id_Organization);
CREATE INDEX idx_task_tags_task      ON task_tags(id_task);
CREATE INDEX idx_task_tags_tag       ON task_tags(id_tag);
CREATE INDEX idx_proj_tags_proj      ON project_tags(id_project);
CREATE INDEX idx_proj_tags_tag       ON project_tags(id_tag);

-- Tasks
CREATE INDEX idx_tasks_project       ON tasks(id_project);
CREATE INDEX idx_tasks_assigned_to   ON tasks(assigned_to);
CREATE INDEX idx_tasks_status        ON tasks(status);
CREATE INDEX idx_tasks_priority      ON tasks(priority);
CREATE INDEX idx_tasks_deadline      ON tasks(deadline);
CREATE INDEX idx_tasks_created_by    ON tasks(created_by);

-- Task Checklists
CREATE INDEX idx_checklists_task     ON task_checklists(id_task);
CREATE INDEX idx_checklists_user     ON task_checklists(assigned_to);

-- Task Dependencies
CREATE INDEX idx_task_dep_task       ON task_dependencies(task_id);
CREATE INDEX idx_task_dep_depends    ON task_dependencies(depends_on_task_id);

-- Milestones
CREATE INDEX idx_milestones_project  ON milestones(id_project);
CREATE INDEX idx_milestones_status   ON milestones(status);
CREATE INDEX idx_milestones_due      ON milestones(due_date);

-- Submissions
CREATE INDEX idx_submissions_project ON submissions(id_project);
CREATE INDEX idx_submissions_task    ON submissions(id_task);
CREATE INDEX idx_submissions_mile    ON submissions(id_milestone);
CREATE INDEX idx_submissions_user    ON submissions(submitted_by);
CREATE INDEX idx_submissions_status  ON submissions(status);

-- Peer Evaluations
CREATE INDEX idx_peer_eval_project   ON peer_evaluations(id_project);
CREATE INDEX idx_peer_eval_evaluator ON peer_evaluations(evaluator_id);
CREATE INDEX idx_peer_eval_evaluated ON peer_evaluations(evaluated_id);

-- Comments
CREATE INDEX idx_comments_task       ON comments(id_task);
CREATE INDEX idx_comments_user       ON comments(id_user);
CREATE INDEX idx_comments_parent     ON comments(parent_comment_id);
CREATE INDEX idx_comment_reactions   ON comment_reactions(id_comment);
CREATE INDEX idx_comment_mentions_c  ON comment_mentions(id_comment);
CREATE INDEX idx_comment_mentions_u  ON comment_mentions(id_user);

-- Files
CREATE INDEX idx_files_task          ON files(id_task);
CREATE INDEX idx_files_project       ON files(id_project);
CREATE INDEX idx_files_comment       ON files(id_comment);
CREATE INDEX idx_files_meeting       ON files(id_meeting);
CREATE INDEX idx_files_submission    ON files(id_submission);
CREATE INDEX idx_files_announcement  ON files(id_announcement);
CREATE INDEX idx_files_uploader      ON files(uploaded_by);

-- Meetings
CREATE INDEX idx_meetings_project    ON meetings(id_project);
CREATE INDEX idx_meetings_date       ON meetings(meeting_date);
CREATE INDEX idx_meetings_status     ON meetings(status);
CREATE INDEX idx_meeting_parts       ON meeting_participants(id_meeting);
CREATE INDEX idx_meeting_parts_user  ON meeting_participants(id_user);

-- Announcements
CREATE INDEX idx_announce_project    ON announcements(id_project);
CREATE INDEX idx_announce_Organization      ON announcements(id_Organization);
CREATE INDEX idx_announce_course     ON announcements(id_course);
CREATE INDEX idx_announce_created    ON announcements(created_at DESC);

-- Notifications
CREATE INDEX idx_notif_user          ON notifications(id_user);
CREATE INDEX idx_notif_sender        ON notifications(id_sender);
CREATE INDEX idx_notif_unread        ON notifications(id_user, is_read)
  WHERE is_read = FALSE;
CREATE INDEX idx_notif_entity        ON notifications(entity_type, entity_id);
CREATE INDEX idx_notif_created       ON notifications(created_at DESC);

-- Invitations
CREATE INDEX idx_invitations_email   ON invitations(invited_email);
CREATE INDEX idx_invitations_token   ON invitations(token);
CREATE INDEX idx_invitations_Organization   ON invitations(id_Organization);
CREATE INDEX idx_invitations_project ON invitations(id_project);
CREATE INDEX idx_invitations_status  ON invitations(status);

-- Time Logs
CREATE INDEX idx_time_logs_task      ON time_logs(id_task);
CREATE INDEX idx_time_logs_user      ON time_logs(id_user);
CREATE INDEX idx_time_logs_project   ON time_logs(id_project);
CREATE INDEX idx_time_logs_dates     ON time_logs(started_at, ended_at);

-- Task History
CREATE INDEX idx_history_task        ON task_history(id_task);
CREATE INDEX idx_history_changed_by  ON task_history(changed_by);
CREATE INDEX idx_history_changed_at  ON task_history(changed_at DESC);

-- Activities
CREATE INDEX idx_activity_project    ON activities(id_project);
CREATE INDEX idx_activity_Organization      ON activities(id_Organization);
CREATE INDEX idx_activity_user       ON activities(id_user);
CREATE INDEX idx_activity_entity     ON activities(entity_type, entity_id);

-- Audit Logs
CREATE INDEX idx_audit_user          ON audit_logs(id_user);
CREATE INDEX idx_audit_entity        ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_action        ON audit_logs(action);
CREATE INDEX idx_audit_created       ON audit_logs(created_at DESC);

-- Templates
CREATE INDEX idx_proj_templates_Organization   ON project_templates(id_Organization);
CREATE INDEX idx_task_templates_project ON task_templates(id_project);

-- ============================================================
-- ALL TRIGGERS
-- ============================================================

-- Fonction updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers updated_at
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_supervisors_updated_at
  BEFORE UPDATE ON supervisors
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_courses_updated_at
  BEFORE UPDATE ON courses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_Organizations_updated_at
  BEFORE UPDATE ON Organizations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at
  BEFORE UPDATE ON projects
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at
  BEFORE UPDATE ON tasks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_task_checklists_updated_at
  BEFORE UPDATE ON task_checklists
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_milestones_updated_at
  BEFORE UPDATE ON milestones
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at
  BEFORE UPDATE ON comments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_meetings_updated_at
  BEFORE UPDATE ON meetings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_announcements_updated_at
  BEFORE UPDATE ON announcements
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_time_logs_updated_at
  BEFORE UPDATE ON time_logs
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_settings_updated_at
  BEFORE UPDATE ON user_settings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_productivity_updated_at
  BEFORE UPDATE ON user_productivity
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_proj_templates_updated_at
  BEFORE UPDATE ON project_templates
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_task_templates_updated_at
  BEFORE UPDATE ON task_templates
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Auto-calcul duration_min (Time Logs)
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

-- Auto-update comment_count (Tasks)
CREATE OR REPLACE FUNCTION update_task_comment_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE tasks
    SET comment_count = comment_count + 1
    WHERE id_task = NEW.id_task;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE tasks
    SET comment_count = GREATEST(0, comment_count - 1)
    WHERE id_task = OLD.id_task;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_task_comment_count
  AFTER INSERT OR DELETE ON comments
  FOR EACH ROW EXECUTE FUNCTION update_task_comment_count();

-- Auto-update attachment_count (Tasks)
CREATE OR REPLACE FUNCTION update_task_attachment_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.id_task IS NOT NULL THEN
    UPDATE tasks
    SET attachment_count = attachment_count + 1
    WHERE id_task = NEW.id_task;
  ELSIF TG_OP = 'DELETE' AND OLD.id_task IS NOT NULL THEN
    UPDATE tasks
    SET attachment_count = GREATEST(0, attachment_count - 1)
    WHERE id_task = OLD.id_task;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_task_attachment_count
  AFTER INSERT OR DELETE ON files
  FOR EACH ROW EXECUTE FUNCTION update_task_attachment_count();

-- Auto-update project progress
CREATE OR REPLACE FUNCTION update_project_progress()
RETURNS TRIGGER AS $$
DECLARE
  v_total     INT;
  v_completed INT;
  v_progress  DECIMAL(5,2);
BEGIN
  SELECT COUNT(*),
         COUNT(*) FILTER (WHERE status = 'DONE')
  INTO   v_total, v_completed
  FROM   tasks
  WHERE  id_project = COALESCE(NEW.id_project, OLD.id_project);

  IF v_total > 0 THEN
    v_progress = ROUND((v_completed::DECIMAL / v_total) * 100, 2);
  ELSE
    v_progress = 0;
  END IF;

  UPDATE projects
  SET    progress        = v_progress,
         total_tasks     = v_total,
         completed_tasks = v_completed
  WHERE  id_project = COALESCE(NEW.id_project, OLD.id_project);

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_project_progress
  AFTER INSERT OR UPDATE OR DELETE ON tasks
  FOR EACH ROW EXECUTE FUNCTION update_project_progress();

-- Auto peer_evaluation overall_score
CREATE OR REPLACE FUNCTION calculate_peer_eval_score()
RETURNS TRIGGER AS $$
DECLARE
  v_count INT := 0;
  v_sum   DECIMAL := 0;
BEGIN
  IF NEW.score_participation IS NOT NULL THEN
    v_sum := v_sum + NEW.score_participation; v_count := v_count + 1;
  END IF;
  IF NEW.score_communication IS NOT NULL THEN
    v_sum := v_sum + NEW.score_communication; v_count := v_count + 1;
  END IF;
  IF NEW.score_quality IS NOT NULL THEN
    v_sum := v_sum + NEW.score_quality; v_count := v_count + 1;
  END IF;
  IF NEW.score_punctuality IS NOT NULL THEN
    v_sum := v_sum + NEW.score_punctuality; v_count := v_count + 1;
  END IF;
  IF NEW.score_teamwork IS NOT NULL THEN
    v_sum := v_sum + NEW.score_teamwork; v_count := v_count + 1;
  END IF;

  IF v_count > 0 THEN
    NEW.overall_score = ROUND(v_sum / v_count, 2);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_peer_eval_score
  BEFORE INSERT OR UPDATE ON peer_evaluations
  FOR EACH ROW EXECUTE FUNCTION calculate_peer_eval_score();

-- Auto is_late (Submissions)
CREATE OR REPLACE FUNCTION calculate_submission_late()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.due_date IS NOT NULL AND NEW.submitted_at > NEW.due_date THEN
    NEW.is_late    = TRUE;
    NEW.late_hours = EXTRACT(
      EPOCH FROM (NEW.submitted_at - NEW.due_date)
    )::INT / 3600;
  ELSE
    NEW.is_late    = FALSE;
    NEW.late_hours = 0;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_submission_late
  BEFORE INSERT OR UPDATE ON submissions
  FOR EACH ROW EXECUTE FUNCTION calculate_submission_late();
