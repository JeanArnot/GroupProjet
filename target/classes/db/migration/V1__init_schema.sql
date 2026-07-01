-- Optional (Trigger Flyway Clean 2)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ENUM alternatives via CHECK constraints
-- 1) USERS
CREATE TABLE users (
    id_user BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    profile_image TEXT,
    role VARCHAR(20) NOT NULL DEFAULT 'MEMBER',
    phone VARCHAR(30),
    university VARCHAR(150),
    speciality VARCHAR(150),
    bio TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    last_login TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT users_role_chk CHECK (role IN ('ADMIN','LEADER','MEMBER')),
    CONSTRAINT users_status_chk CHECK (status IN ('ACTIVE','INACTIVE','BLOCKED'))
);

-- 2) OrganizationS
CREATE TABLE Organizations (
    id_Organization BIGSERIAL PRIMARY KEY,
    Organization_name VARCHAR(150) NOT NULL,
    description TEXT,
    created_by BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
    Organization_image TEXT,
    access_code VARCHAR(50) UNIQUE,
    visibility VARCHAR(20) NOT NULL DEFAULT 'PRIVATE',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT Organizations_visibility_chk CHECK (visibility IN ('PRIVATE','PUBLIC')),
    CONSTRAINT Organizations_status_chk CHECK (status IN ('ACTIVE','ARCHIVED'))
);

-- 3) Organization MEMBERS
CREATE TABLE Organization_members (
    id_Organization_member BIGSERIAL PRIMARY KEY,
    id_Organization BIGINT NOT NULL REFERENCES Organizations(id_Organization) ON DELETE CASCADE,
    id_user BIGINT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
    member_role VARCHAR(20) NOT NULL DEFAULT 'MEMBER',
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_Organization_member UNIQUE (id_Organization, id_user),
    CONSTRAINT Organization_members_role_chk CHECK (member_role IN ('ADMIN','ENCADREUR','MEMBRE'))
);

-- 4) PROJECTS
CREATE TABLE projects (
    id_project BIGSERIAL PRIMARY KEY,
    id_Organization BIGINT NOT NULL REFERENCES Organizations(id_Organization) ON DELETE CASCADE,
    project_name VARCHAR(200) NOT NULL,
    description TEXT,
    project_code VARCHAR(50) UNIQUE,
    status VARCHAR(30) NOT NULL DEFAULT 'PLANNING',
    priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM',
    progress DECIMAL(5,2) NOT NULL DEFAULT 0,
    health_status VARCHAR(20) NOT NULL DEFAULT 'GOOD',
    start_date DATE,
    end_date DATE,
    estimated_hours INT,
    completed_tasks INT NOT NULL DEFAULT 0,
    total_tasks INT NOT NULL DEFAULT 0,
    project_color VARCHAR(20),
    archived BOOLEAN NOT NULL DEFAULT FALSE,
    created_by BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT projects_status_chk CHECK (status IN ('PLANNING','ACTIVE','ON_HOLD','COMPLETED','CANCELLED')),
    CONSTRAINT projects_priority_chk CHECK (priority IN ('LOW','MEDIUM','HIGH','URGENT')),
    CONSTRAINT projects_health_chk CHECK (health_status IN ('GOOD','WARNING','CRITICAL')),
    CONSTRAINT projects_progress_chk CHECK (progress >= 0 AND progress <= 100),
    CONSTRAINT projects_hours_chk CHECK (estimated_hours IS NULL OR estimated_hours >= 0),
    CONSTRAINT projects_tasks_chk CHECK (completed_tasks >= 0 AND total_tasks >= 0 AND completed_tasks <= total_tasks)
);

-- 5) PROJECT MEMBERS
CREATE TABLE project_members (
    id_project_member BIGSERIAL PRIMARY KEY,
    id_project BIGINT NOT NULL REFERENCES projects(id_project) ON DELETE CASCADE,
    id_user BIGINT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
    role_in_project VARCHAR(30) NOT NULL DEFAULT 'MEMBER',
    assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_project_member UNIQUE (id_project, id_user),
    CONSTRAINT project_members_role_chk CHECK (role_in_project IN ('CHEF_PROJET','MEMBRE'))
);

-- 6) TASKS
CREATE TABLE tasks (
    id_task BIGSERIAL PRIMARY KEY,
    id_project BIGINT NOT NULL REFERENCES projects(id_project) ON DELETE CASCADE,
    assigned_to BIGINT REFERENCES users(id_user) ON DELETE SET NULL,
    task_title VARCHAR(200) NOT NULL,
    description TEXT,
    task_code VARCHAR(50) UNIQUE,
    priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM',
    status VARCHAR(20) NOT NULL DEFAULT 'TODO',
    progress DECIMAL(5,2) NOT NULL DEFAULT 0,
    estimated_time INT,
    spent_time INT NOT NULL DEFAULT 0,
    start_date TIMESTAMP,
    deadline TIMESTAMP,
    completed_at TIMESTAMP,
    is_blocked BOOLEAN NOT NULL DEFAULT FALSE,
    difficulty_level VARCHAR(20),
    reminder_sent BOOLEAN NOT NULL DEFAULT FALSE,
    attachment_count INT NOT NULL DEFAULT 0,
    comment_count INT NOT NULL DEFAULT 0,
    created_by BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT tasks_status_chk CHECK (status IN ('TODO','IN_PROGRESS','REVIEW','DONE','CANCELLED')),
    CONSTRAINT tasks_priority_chk CHECK (priority IN ('LOW','MEDIUM','HIGH','URGENT')),
    CONSTRAINT tasks_progress_chk CHECK (progress >= 0 AND progress <= 100),
    CONSTRAINT tasks_time_chk CHECK (spent_time >= 0 AND (estimated_time IS NULL OR estimated_time >= 0)),
    CONSTRAINT tasks_diff_chk CHECK (difficulty_level IS NULL OR difficulty_level IN ('EASY','MEDIUM','HARD','EXPERT'))
);

-- 7) TASK DEPENDENCIES
CREATE TABLE task_dependencies (
    id_dependency BIGSERIAL PRIMARY KEY,
    task_id BIGINT NOT NULL REFERENCES tasks(id_task) ON DELETE CASCADE,
    depends_on_task_id BIGINT NOT NULL REFERENCES tasks(id_task) ON DELETE CASCADE,
    CONSTRAINT uq_task_dependency UNIQUE (task_id, depends_on_task_id),
    CONSTRAINT task_dependency_self_chk CHECK (task_id <> depends_on_task_id)
);

-- 8) MILESTONES
CREATE TABLE milestones (
    id_milestone BIGSERIAL PRIMARY KEY,
    id_project BIGINT NOT NULL REFERENCES projects(id_project) ON DELETE CASCADE,
    milestone_name VARCHAR(200) NOT NULL,
    description TEXT,
    due_date DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    completion_percentage DECIMAL(5,2) NOT NULL DEFAULT 0,
    created_by BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT milestones_status_chk CHECK (status IN ('PENDING','IN_PROGRESS','DONE','OVERDUE','CANCELLED')),
    CONSTRAINT milestones_completion_chk CHECK (completion_percentage >= 0 AND completion_percentage <= 100)
);

-- 9) NOTIFICATIONS
CREATE TABLE notifications (
    id_notification BIGSERIAL PRIMARY KEY,
    id_user BIGINT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT notifications_type_chk CHECK (notification_type IN ('TASK','PROJECT','Organization','MEETING','SYSTEM'))
);

-- 10) COMMENTS
CREATE TABLE comments (
    id_comment BIGSERIAL PRIMARY KEY,
    id_task BIGINT NOT NULL REFERENCES tasks(id_task) ON DELETE CASCADE,
    id_user BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 11) FILES
CREATE TABLE files (
    id_file BIGSERIAL PRIMARY KEY,
    id_task BIGINT NOT NULL REFERENCES tasks(id_task) ON DELETE CASCADE,
    uploaded_by BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
    file_name VARCHAR(255) NOT NULL,
    file_url TEXT NOT NULL,
    file_size BIGINT,
    file_type VARCHAR(50),
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT files_size_chk CHECK (file_size IS NULL OR file_size >= 0)
);

-- 12) ACTIVITIES
CREATE TABLE activities (
    id_activity BIGSERIAL PRIMARY KEY,
    id_user BIGINT REFERENCES users(id_user) ON DELETE SET NULL,
    id_project BIGINT REFERENCES projects(id_project) ON DELETE CASCADE,
    activity_type VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 13) MEETINGS
CREATE TABLE meetings (
    id_meeting BIGSERIAL PRIMARY KEY,
    id_project BIGINT NOT NULL REFERENCES projects(id_project) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    meeting_link TEXT,
    meeting_date TIMESTAMP NOT NULL,
    duration_minutes INT,
    created_by BIGINT NOT NULL REFERENCES users(id_user) ON DELETE RESTRICT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT meetings_duration_chk CHECK (duration_minutes IS NULL OR duration_minutes > 0)
);

-- 14) MEETING PARTICIPANTS
CREATE TABLE meeting_participants (
    id_participant BIGSERIAL PRIMARY KEY,
    id_meeting BIGINT NOT NULL REFERENCES meetings(id_meeting) ON DELETE CASCADE,
    id_user BIGINT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
    attendance_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    CONSTRAINT uq_meeting_participant UNIQUE (id_meeting, id_user),
    CONSTRAINT meeting_participants_status_chk CHECK (attendance_status IN ('PENDING','PRESENT','ABSENT','LATE'))
);

-- 15) TASK HISTORY
CREATE TABLE task_history (
    id_history BIGSERIAL PRIMARY KEY,
    id_task BIGINT NOT NULL REFERENCES tasks(id_task) ON DELETE CASCADE,
    changed_by BIGINT REFERENCES users(id_user) ON DELETE SET NULL,
    old_status VARCHAR(20),
    new_status VARCHAR(20),
    change_description TEXT,
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 16) USER PRODUCTIVITY
CREATE TABLE user_productivity (
    id_productivity BIGSERIAL PRIMARY KEY,
    id_user BIGINT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
    completed_tasks INT NOT NULL DEFAULT 0,
    late_tasks INT NOT NULL DEFAULT 0,
    total_hours_worked INT NOT NULL DEFAULT 0,
    productivity_score DECIMAL(5,2) NOT NULL DEFAULT 0,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_user_productivity UNIQUE (id_user),
    CONSTRAINT user_productivity_chk CHECK (
        completed_tasks >= 0
        AND late_tasks >= 0
        AND total_hours_worked >= 0
        AND productivity_score >= 0
        AND productivity_score <= 100
    )
);

-- Recommended indexes
CREATE INDEX idx_Organizations_created_by ON Organizations(created_by);
CREATE INDEX idx_projects_Organization ON projects(id_Organization);
CREATE INDEX idx_tasks_project ON tasks(id_project);
CREATE INDEX idx_tasks_assigned_to ON tasks(assigned_to);
CREATE INDEX idx_comments_task ON comments(id_task);
CREATE INDEX idx_files_task ON files(id_task);
CREATE INDEX idx_notifications_user ON notifications(id_user);
CREATE INDEX idx_meetings_project ON meetings(id_project);
CREATE INDEX idx_activity_project ON activities(id_project);
CREATE INDEX idx_history_task ON task_history(id_task);
