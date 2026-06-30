-- V7__insert_academic_mock_data.sql
-- ==========================================
-- MOCK DATA FOR ALL 43 ACADEMIC TABLES
-- ==========================================

-- 0. CLEAR EXISTING DATA
TRUNCATE TABLE reports, user_stats, admin_actions, system_configs, calendar_events, user_sessions, email_verifications, password_resets, task_templates, project_templates, user_productivity, user_settings, audit_logs, activities, task_history, time_logs, invitations, notifications, files, announcements, meeting_participants, meetings, comment_mentions, comment_reactions, comments, peer_evaluations, submissions, milestones, task_dependencies, task_checklists, task_tags, tasks, project_tags, tags, project_members, projects, Organization_members, Organizations, courses, academic_years, supervisors, users RESTART IDENTITY CASCADE;

-- 1. USERS
INSERT INTO users (first_name, last_name, username, email, password, role, university, speciality, academic_level, status) VALUES
('John', 'Doe', 'johndoe', 'john.doe@univ.com', 'password123', 'LEADER', 'Univ Antananarivo', 'Génie Logiciel', 'L3', 'ACTIVE'),
('Sarah', 'Johnson', 'sjohnson', 'sarah.j@univ.com', 'password123', 'MEMBER', 'Univ Toamasina', 'Réseaux', 'M1', 'ACTIVE'),
('Mike', 'Wilson', 'mwilson', 'mike.w@univ.com', 'password123', 'MEMBER', 'Univ Mahajanga', 'Design', 'L2', 'ACTIVE'),
('Dr. Alan', 'Turing', 'aturing', 'alan.t@univ.com', 'password123', 'SUPERVISOR', 'Univ Antananarivo', 'IA', 'PhD', 'ACTIVE'),
('Prof. Ada', 'Lovelace', 'alovelace', 'ada.l@univ.com', 'password123', 'SUPERVISOR', 'Univ Toamasina', 'Math', 'PhD', 'ACTIVE'),
('Admin', 'System', 'admin', 'admin@univ.com', 'password123', 'ADMIN', 'System', 'System', 'OTHER', 'ACTIVE');

-- 2. SUPERVISORS
INSERT INTO supervisors (id_user, title, department, university, office) VALUES
(4, 'Dr.', 'Informatique', 'Univ Antananarivo', 'Salle 404'),
(5, 'Prof.', 'Mathématiques', 'Univ Toamasina', 'Salle 505');

-- 3. ACADEMIC YEARS
INSERT INTO academic_years (year_label, start_date, end_date, is_current) VALUES
('2023-2024', '2023-09-01', '2024-07-31', FALSE),
('2024-2025', '2024-09-01', '2025-07-31', TRUE),
('2025-2026', '2025-09-01', '2026-07-31', FALSE);

-- 4. COURSES
INSERT INTO courses (id_academic_year, course_name, course_code, credits, semester) VALUES
(2, 'Génie Logiciel Avancé', 'INF301', 6, 'S5'),
(2, 'Développement Web', 'INF302', 4, 'S5'),
(2, 'Intelligence Artificielle', 'INF303', 5, 'S6');

-- 5. OrganizationS
INSERT INTO Organizations (Organization_name, created_by, status) VALUES
('Team Alpha', 1, 'ACTIVE'),
('Web Dev Squad', 2, 'ACTIVE'),
('AI Researchers', 4, 'ACTIVE');

-- 6. Organization MEMBERS
INSERT INTO Organization_members (id_Organization, id_user, member_role) VALUES
(1, 1, 'LEADER'), (1, 2, 'MEMBER'), (1, 3, 'MEMBER'),
(2, 2, 'LEADER'), (2, 3, 'MEMBER');

-- 7. PROJECTS
INSERT INTO projects (id_Organization, id_course, id_academic_year, id_supervisor, project_name, project_code, status, progress, created_by) VALUES
(1, 1, 2, 1, 'Application Mobile', 'PROJ-001', 'ACTIVE', 72.00, 1),
(2, 2, 2, 2, 'Plateforme Web', 'PROJ-002', 'ACTIVE', 48.00, 2),
(3, 3, 2, 1, 'IA Chatbot', 'PROJ-003', 'ACTIVE', 30.00, 4);

-- 8. PROJECT MEMBERS
INSERT INTO project_members (id_project, id_user, role_in_project) VALUES
(1, 1, 'LEADER'), (1, 2, 'MEMBER'), (1, 3, 'MEMBER'),
(2, 2, 'LEADER'), (2, 3, 'MEMBER');

-- 9. TAGS
INSERT INTO tags (id_Organization, tag_name, tag_color) VALUES
(1, 'Frontend', '#3B82F6'), (1, 'Backend', '#10B981'), (1, 'Urgent', '#EF4444');

-- 10. PROJECT TAGS
INSERT INTO project_tags (id_project, id_tag, tagged_by) VALUES
(1, 1, 1), (1, 2, 1);

-- 11. TASKS
INSERT INTO tasks (id_project, assigned_to, task_title, status, priority, created_by) VALUES
(1, 1, 'Conception UI/UX', 'IN_PROGRESS', 'HIGH', 1),
(1, 2, 'Intégration API', 'TODO', 'MEDIUM', 1),
(1, 3, 'Base de données', 'DONE', 'HIGH', 1),
(2, 2, 'Mise en place Serveur', 'TODO', 'HIGH', 2),
(3, 4, 'Entraînement Modèle', 'IN_PROGRESS', 'URGENT', 4);

-- 12. TASK TAGS
INSERT INTO task_tags (id_task, id_tag, tagged_by) VALUES
(1, 1, 1), (2, 2, 1), (3, 2, 1);

-- 13. TASK CHECKLISTS
INSERT INTO task_checklists (id_task, item_text, is_done) VALUES
(1, 'Wireframes', TRUE), (1, 'Maquettes', FALSE), (1, 'Prototypage', FALSE);

-- 14. TASK DEPENDENCIES
INSERT INTO task_dependencies (task_id, depends_on_task_id) VALUES
(2, 3); -- API depends on DB

-- 15. MILESTONES
INSERT INTO milestones (id_project, milestone_name, status, created_by) VALUES
(1, 'Phase 1 - Analyse', 'DONE', 1),
(1, 'Phase 2 - Conception', 'IN_PROGRESS', 1),
(1, 'Phase 3 - Dev', 'PENDING', 1);

-- 16. SUBMISSIONS
INSERT INTO submissions (id_project, id_task, submitted_by, submission_title, status, grade) VALUES
(1, 3, 3, 'Livrable Base de données', 'APPROVED', 18.5),
(1, 1, 1, 'Livrable UI', 'PENDING', NULL);

-- 17. PEER EVALUATIONS
INSERT INTO peer_evaluations (id_project, evaluator_id, evaluated_id, overall_score) VALUES
(1, 1, 2, 4.5), (1, 2, 1, 4.0), (1, 3, 1, 5.0);

-- 18. COMMENTS
INSERT INTO comments (id_task, id_user, comment_text) VALUES
(1, 2, 'Pour ce sujet, un mode sombre ?'),
(1, 1, 'Bien sûr, je vais lajouter.');

-- 19. COMMENT REACTIONS
INSERT INTO comment_reactions (id_comment, id_user, emoji) VALUES
(1, 1, '👍');

-- 20. COMMENT MENTIONS
INSERT INTO comment_mentions (id_comment, id_user) VALUES
(1, 1);

-- 21. MEETINGS
INSERT INTO meetings (id_project, title, meeting_date, created_by) VALUES
(1, 'Réunion de lancement', '2025-04-10 10:00:00', 1),
(1, 'Revue de sprint', '2025-04-17 14:00:00', 1);

-- 22. MEETING PARTICIPANTS
INSERT INTO meeting_participants (id_meeting, id_user, attendance_status) VALUES
(1, 1, 'PRESENT'), (1, 2, 'PRESENT'), (1, 3, 'ABSENT');

-- 23. ANNOUNCEMENTS
INSERT INTO announcements (id_project, created_by, title, content) VALUES
(1, 1, 'Changement de salle', 'La réunion se fera en B201');

-- 24. FILES
INSERT INTO files (id_project, uploaded_by, file_name, original_name, file_url) VALUES
(1, 1, 'cahier_charges.pdf', 'cahier_charges.pdf', 'http://url/file.pdf');

-- 25. NOTIFICATIONS
INSERT INTO notifications (id_user, title, message, notification_type) VALUES
(1, 'Nouvelle tâche', 'Vous avez une tâche', 'TASK_ASSIGNED'),
(2, 'Réunion planifiée', 'Sprint', 'MEETING_SCHEDULED');

-- 26. INVITATIONS
INSERT INTO invitations (id_Organization, invited_by, invited_email, token, expires_at) VALUES
(1, 1, 'new@univ.com', 'token123', '2025-12-31 00:00:00');

-- 27. TIME LOGS
INSERT INTO time_logs (id_task, id_user, started_at, ended_at, duration_min) VALUES
(1, 1, '2025-04-01 10:00:00', '2025-04-01 12:00:00', 120);

-- 28. TASK HISTORY
INSERT INTO task_history (id_task, changed_by, field_changed, new_value) VALUES
(1, 1, 'status', 'IN_PROGRESS');

-- 29. ACTIVITIES
INSERT INTO activities (id_project, id_user, activity_type) VALUES
(1, 1, 'CREATED_TASK');

-- 30. AUDIT LOGS
INSERT INTO audit_logs (id_user, entity_type, action) VALUES
(1, 'PROJECT', 'CREATE');

-- 31. USER SETTINGS
INSERT INTO user_settings (id_user, theme) VALUES
(1, 'DARK'), (2, 'LIGHT'), (3, 'SYSTEM');

-- 32. USER PRODUCTIVITY
INSERT INTO user_productivity (id_user, completed_tasks, productivity_score) VALUES
(1, 10, 85.5), (2, 8, 90.0);

-- 33. PROJECT TEMPLATES
INSERT INTO project_templates (template_name, template_data, created_by) VALUES
('Template Dev Web', '{"structure": []}', 1);

-- 34. TASK TEMPLATES
INSERT INTO task_templates (template_name, template_data, created_by) VALUES
('Template Bug Fix', '{"structure": []}', 1);

-- 35. PASSWORD RESETS
INSERT INTO password_resets (id_user, email, token, expires_at) VALUES
(1, 'john.doe@univ.com', 'reset123', '2025-12-31 00:00:00');

-- 36. EMAIL VERIFICATIONS
INSERT INTO email_verifications (id_user, email, token, expires_at) VALUES
(1, 'john.doe@univ.com', 'verify123', '2025-12-31 00:00:00');

-- 37. SESSIONS
INSERT INTO user_sessions (id_user, session_token, expires_at) VALUES
(1, 'sess123', '2025-12-31 00:00:00');

-- 38. CALENDAR EVENTS
INSERT INTO calendar_events (id_user, title, start_datetime, created_by) VALUES
(1, 'Examen', '2025-06-15 08:00:00', 1);

-- 39. SYSTEM CONFIGS
INSERT INTO system_configs (config_key, config_value) VALUES
('APP_NAME', 'groupprojet Academic');

-- 40. ADMIN ACTIONS
INSERT INTO admin_actions (id_admin, action_type) VALUES
(6, 'SYSTEM_MAINTENANCE');

-- 41. USER STATS
-- Handled by triggers automatically upon insert, but we can insert if needed:
INSERT INTO user_stats (id_user, total_projects) VALUES
(1, 5) ON CONFLICT (id_user) DO NOTHING;

-- 42. REPORTS
INSERT INTO reports (id_user, report_name, report_type) VALUES
(1, 'Bilan Mensuel', 'PROJECT_SUMMARY');

-- 43. SYSTEM SETTINGS (Handled by 39)
-- All 43 tables populated.
