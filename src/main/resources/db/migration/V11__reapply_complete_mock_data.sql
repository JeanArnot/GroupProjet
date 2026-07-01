-- V8__replace_with_complete_mock_data.sql

ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_chk;
ALTER TABLE submissions DROP CONSTRAINT IF EXISTS submissions_status_chk;
ALTER TABLE announcements DROP CONSTRAINT IF EXISTS announce_priority_chk;
ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_type_chk;

-- Delete all existing data first to start fresh
DELETE FROM reports;
DELETE FROM admin_actions;
DELETE FROM system_configs;
DELETE FROM calendar_events;
DELETE FROM user_sessions;
DELETE FROM email_verifications;
DELETE FROM password_resets;
DELETE FROM task_templates;
DELETE FROM project_templates;
DELETE FROM user_productivity;
DELETE FROM user_settings;
DELETE FROM audit_logs;
DELETE FROM activities;
DELETE FROM task_history;
DELETE FROM time_logs;
DELETE FROM invitations;
DELETE FROM notifications;
DELETE FROM files;
DELETE FROM announcements;
DELETE FROM meeting_participants;
DELETE FROM meetings;
DELETE FROM comment_mentions;
DELETE FROM comment_reactions;
DELETE FROM comments;
DELETE FROM peer_evaluations;
DELETE FROM submissions;
DELETE FROM milestones;
DELETE FROM task_dependencies;
DELETE FROM task_checklists;
DELETE FROM task_tags;
DELETE FROM tasks;
DELETE FROM project_tags;
DELETE FROM tags;
DELETE FROM project_members;
DELETE FROM projects;
DELETE FROM Organization_members;
DELETE FROM Organizations;
DELETE FROM courses;
DELETE FROM academic_years;
DELETE FROM supervisors;
DELETE FROM user_stats;
DELETE FROM users;

-- 1. USERS (Roles: ADMIN, ETUDIANT, ENCADREUR, CHEF_PROJET)
INSERT INTO users (id_user, first_name, last_name, username, email, password, role, university, speciality, academic_level, status) VALUES
(1, 'Admin', 'Global', 'admin', 'admin@univ.com', '$2a$10$JbxXidmfF5/AO4mkVoNOK.0a.NnXI4SuPGQVAH7RZEsx/hUjmCLg2', 'ADMIN', 'Système', 'Admin', 'OTHER', 'ACTIVE'),
(2, 'Marie', 'Curie', 'marie.c', 'marie.curie@univ.com', '$2a$10$JbxXidmfF5/AO4mkVoNOK.0a.NnXI4SuPGQVAH7RZEsx/hUjmCLg2', 'ENCADREUR', 'Univ Antananarivo', 'Mathématiques', 'PhD', 'ACTIVE'),
(3, 'Alan', 'Turing', 'alan.t', 'alan.turing@univ.com', '$2a$10$JbxXidmfF5/AO4mkVoNOK.0a.NnXI4SuPGQVAH7RZEsx/hUjmCLg2', 'ENCADREUR', 'Univ Antananarivo', 'Informatique', 'PhD', 'ACTIVE'),
(4, 'Ada', 'Lovelace', 'ada.l', 'ada.lovelace@univ.com', '$2a$10$JbxXidmfF5/AO4mkVoNOK.0a.NnXI4SuPGQVAH7RZEsx/hUjmCLg2', 'CHEF_PROJET', 'Univ Antananarivo', 'Génie Logiciel', 'M2', 'ACTIVE'),
(5, 'Linus', 'Torvalds', 'linus.t', 'linus.torvalds@univ.com', '$2a$10$JbxXidmfF5/AO4mkVoNOK.0a.NnXI4SuPGQVAH7RZEsx/hUjmCLg2', 'CHEF_PROJET', 'Univ Antananarivo', 'Systèmes', 'M2', 'ACTIVE'),
(6, 'Grace', 'Hopper', 'grace.h', 'grace.hopper@univ.com', '$2a$10$JbxXidmfF5/AO4mkVoNOK.0a.NnXI4SuPGQVAH7RZEsx/hUjmCLg2', 'ETUDIANT', 'Univ Antananarivo', 'Développement Web', 'L3', 'ACTIVE'),
(7, 'Tim', 'Berners-Lee', 'tim.b', 'tim.berners@univ.com', '$2a$10$JbxXidmfF5/AO4mkVoNOK.0a.NnXI4SuPGQVAH7RZEsx/hUjmCLg2', 'ETUDIANT', 'Univ Antananarivo', 'Réseaux', 'L3', 'ACTIVE'),
(8, 'Margaret', 'Hamilton', 'margaret.h', 'margaret.hamilton@univ.com', '$2a$10$JbxXidmfF5/AO4mkVoNOK.0a.NnXI4SuPGQVAH7RZEsx/hUjmCLg2', 'ETUDIANT', 'Univ Antananarivo', 'Compilateurs', 'M1', 'ACTIVE'),
(9, 'Bjarne', 'Stroustrup', 'bjarne.s', 'bjarne.s@univ.com', '$2a$10$JbxXidmfF5/AO4mkVoNOK.0a.NnXI4SuPGQVAH7RZEsx/hUjmCLg2', 'ETUDIANT', 'Univ Toamasina', 'C++', 'M1', 'ACTIVE'),
(10, 'Dennis', 'Ritchie', 'dennis.r', 'dennis.ritchie@univ.com', '$2a$10$JbxXidmfF5/AO4mkVoNOK.0a.NnXI4SuPGQVAH7RZEsx/hUjmCLg2', 'ETUDIANT', 'Univ Fianarantsoa', 'C', 'L2', 'ACTIVE'),
(11, 'Ken', 'Thompson', 'ken.t', 'ken.thompson@univ.com', '$2a$10$JbxXidmfF5/AO4mkVoNOK.0a.NnXI4SuPGQVAH7RZEsx/hUjmCLg2', 'ETUDIANT', 'Univ Fianarantsoa', 'Systèmes', 'L2', 'ACTIVE'),
(12, 'Donald', 'Knuth', 'dennis.k', 'donald.knuth@univ.com', '$2a$10$JbxXidmfF5/AO4mkVoNOK.0a.NnXI4SuPGQVAH7RZEsx/hUjmCLg2', 'ETUDIANT', 'Univ Antananarivo', 'Algorithmique', 'L3', 'ACTIVE');

-- 1.5 SUPERVISORS
INSERT INTO supervisors (id_supervisor, id_user, title, department, university, office) VALUES
(2, 2, 'Prof.', 'Mathématiques', 'Univ Antananarivo', 'Bureau 201'),
(3, 3, 'Dr.', 'Informatique', 'Univ Antananarivo', 'Bureau 305');

-- 2. ACADEMIC YEARS
INSERT INTO academic_years (id_academic_year, year_label, start_date, end_date, is_current) VALUES
(1, '2025-2026', '2025-09-01', '2026-07-31', TRUE);

-- 3. COURSES
INSERT INTO courses (id_course, id_academic_year, course_name, course_code, credits, semester) VALUES
(1, 1, 'Génie Logiciel Avancé', 'INF401', 6, 'S7'),
(2, 1, 'Administration Système', 'INF402', 4, 'S7'),
(3, 1, 'Développement Mobile', 'INF403', 5, 'S8');

-- 4. OrganizationS
INSERT INTO Organizations (id_Organization, Organization_name, created_by, status) VALUES
(1, 'Alpha Tech', 4, 'ACTIVE'),
(2, 'Beta Systems', 5, 'ACTIVE');

-- 5. Organization MEMBERS
INSERT INTO Organization_members (id_Organization, id_user, member_role) VALUES
(1, 4, 'LEADER'), (1, 6, 'MEMBER'), (1, 7, 'MEMBER'), (1, 8, 'MEMBER'),
(2, 5, 'LEADER'), (2, 9, 'MEMBER'), (2, 10, 'MEMBER'), (2, 11, 'MEMBER'), (2, 12, 'MEMBER');

-- 6. PROJECTS
INSERT INTO projects (id_project, id_Organization, id_course, id_academic_year, id_supervisor, project_name, project_code, status, progress, created_by, description) VALUES
(1, 1, 1, 1, 2, 'Plateforme de Gestion Académique', 'PROJ-ACAD-01', 'ACTIVE', 65.00, 4, 'Création d''une plateforme de gestion des projets pour l''université.'),
(2, 1, 3, 1, 3, 'Application Mobile Flutter', 'PROJ-MOB-02', 'ACTIVE', 45.00, 4, 'Développement de l''application mobile associée au projet académique.'),
(3, 2, 2, 1, 3, 'Automatisation des Serveurs', 'PROJ-SYS-03', 'ACTIVE', 80.00, 5, 'Scripts et outils d''automatisation de déploiement.'),
(4, 2, 3, 1, 2, 'Application de Chat Temps Réel', 'PROJ-MOB-04', 'ACTIVE', 15.00, 5, 'Chat avec WebSockets et Flutter.');

-- 7. PROJECT MEMBERS
INSERT INTO project_members (id_project, id_user, role_in_project) VALUES
(1, 4, 'LEADER'), (1, 6, 'MEMBER'), (1, 7, 'MEMBER'),
(2, 4, 'LEADER'), (2, 8, 'MEMBER'),
(3, 5, 'LEADER'), (3, 9, 'MEMBER'), (3, 10, 'MEMBER'),
(4, 5, 'LEADER'), (4, 11, 'MEMBER'), (4, 12, 'MEMBER');

-- 8. TASKS
INSERT INTO tasks (id_task, id_project, assigned_to, task_title, status, priority, created_by, progress, description) VALUES
(1, 1, 6, 'Conception de la BDD', 'DONE', 'HIGH', 4, 1.00, 'Modéliser la base de données relationnelle.'),
(2, 1, 7, 'Développement Backend API', 'IN_PROGRESS', 'URGENT', 4, 0.60, 'Créer les endpoints REST avec Spring Boot.'),
(3, 1, 4, 'Mise en place Sécurité JWT', 'TODO', 'HIGH', 4, 0.00, 'Ajouter Spring Security et les tokens.'),
(4, 2, 8, 'Maquettage UI/UX', 'DONE', 'MEDIUM', 4, 1.00, 'Créer les maquettes sur Figma.'),
(5, 2, 6, 'Intégration Frontend Flutter', 'IN_PROGRESS', 'HIGH', 4, 0.40, 'Intégrer les écrans Flutter et l''API.'),
(6, 3, 9, 'Script Bash', 'DONE', 'MEDIUM', 5, 1.00, 'Script de démarrage.'),
(7, 3, 10, 'Configuration Docker', 'IN_PROGRESS', 'HIGH', 5, 0.80, 'Créer le Dockerfile et docker-compose.'),
(8, 4, 11, 'UI du Chat', 'TODO', 'MEDIUM', 5, 0.00, 'Interface Flutter du Chat.'),
(9, 4, 12, 'Serveur WebSocket', 'IN_PROGRESS', 'HIGH', 5, 0.30, 'Configuration WebSocket sur Spring Boot.');

-- 9. MILESTONES
INSERT INTO milestones (id_milestone, id_project, milestone_name, status, created_by, due_date) VALUES
(1, 1, 'Phase 1 - Spécifications', 'DONE', 4, '2025-10-15 00:00:00'),
(2, 1, 'Phase 2 - Architecture', 'IN_PROGRESS', 4, '2025-11-15 00:00:00'),
(3, 1, 'Phase 3 - Développement', 'PENDING', 4, '2025-12-20 00:00:00'),
(4, 2, 'Maquettes Validées', 'DONE', 4, '2025-10-25 00:00:00'),
(5, 3, 'Déploiement Automatisé', 'IN_PROGRESS', 5, '2025-11-05 00:00:00');

-- 10. SUBMISSIONS
INSERT INTO submissions (id_submission, id_project, id_task, submitted_by, submission_title, status, grade, feedback) VALUES
(1, 1, 1, 6, 'Rendu Modèle BDD', 'APPROVED', 17.5, 'Excellent modèle, très complet.'),
(2, 2, 4, 8, 'Rendu Maquettes Figma', 'APPROVED', 16.0, 'Bonnes interfaces, attention aux contrastes.'),
(3, 3, 6, 9, 'Rendu Script', 'APPROVED', 14.5, 'Le script fonctionne, mais manque de commentaires.'),
(4, 1, 2, 7, 'Code Backend V1', 'PENDING', NULL, NULL);

-- 11. MEETINGS
INSERT INTO meetings (id_meeting, id_project, title, meeting_date, created_by, duration_minutes, location) VALUES
(1, 1, 'Revue de Sprint 1', '2025-10-20 10:00:00', 4, 60, 'Salle B102'),
(2, 1, 'Point Backend', '2025-11-05 14:00:00', 4, 45, 'Google Meet'),
(3, 2, 'Validation Design', '2025-10-26 09:00:00', 4, 30, 'Salle B103'),
(4, 3, 'Point Infra', '2025-11-10 11:00:00', 5, 60, 'Discord');

-- 12. ANNOUNCEMENTS
INSERT INTO announcements (id_announcement, id_project, created_by, title, content, priority) VALUES
(1, 1, 2, 'Rappel Évaluation', 'N''oubliez pas de soumettre le livrable de la phase 2 avant vendredi.', 'HIGH'),
(2, 1, 4, 'Réunion déplacée', 'La revue de sprint est décalée à 11h.', 'NORMAL'),
(3, 3, 3, 'Nouvelle consigne Docker', 'Veuillez utiliser l''image Alpine.', 'URGENT');

-- 13. FILES
INSERT INTO files (id_file, id_project, uploaded_by, file_name, original_name, file_url, file_size, file_type) VALUES
(1, 1, 4, 'cdc_projet1.pdf', 'cdc_projet1.pdf', '/uploads/cdc_projet1.pdf', 2500000, 'application/pdf'),
(2, 2, 8, 'maquettes_v1.fig', 'maquettes_v1.fig', '/uploads/maquettes.fig', 15000000, 'application/figma'),
(3, 3, 5, 'schema_infra.png', 'schema_infra.png', '/uploads/schema.png', 800000, 'image/png');

-- 14. NOTIFICATIONS
INSERT INTO notifications (id_notification, id_user, title, message, notification_type, is_read) VALUES
(1, 6, 'Tâche assignée', 'Vous avez été assigné à Conception BDD', 'TASK_ASSIGNED', TRUE),
(2, 7, 'Tâche assignée', 'Vous avez été assigné à Dev Backend', 'TASK_ASSIGNED', FALSE),
(3, 4, 'Nouvelle soumission', 'Grace a soumis le modèle BDD', 'TASK_DONE', FALSE),
(4, 2, 'Évaluation requise', 'Des soumissions attendent votre évaluation', 'PROJECT_UPDATED', FALSE);

-- 15. CALENDAR EVENTS
INSERT INTO calendar_events (id_event, id_user, title, start_datetime, end_datetime, created_by, color, location) VALUES
(1, 6, 'Soutenance mi-parcours', '2025-12-15 09:00:00', '2025-12-15 12:00:00', 6, '#EF4444', 'Amphi A'),
(2, 4, 'Rendu Phase 2', '2025-11-15 23:59:00', '2025-11-15 23:59:00', 4, '#F59E0B', 'En ligne');

-- Adjust sequences
SELECT setval(pg_get_serial_sequence('supervisors', 'id_supervisor'), coalesce(max(id_supervisor)+1, 1), false) FROM supervisors;
SELECT setval(pg_get_serial_sequence('users', 'id_user'), coalesce(max(id_user)+1, 1), false) FROM users;
SELECT setval(pg_get_serial_sequence('projects', 'id_project'), coalesce(max(id_project)+1, 1), false) FROM projects;
SELECT setval(pg_get_serial_sequence('tasks', 'id_task'), coalesce(max(id_task)+1, 1), false) FROM tasks;
SELECT setval(pg_get_serial_sequence('milestones', 'id_milestone'), coalesce(max(id_milestone)+1, 1), false) FROM milestones;
SELECT setval(pg_get_serial_sequence('submissions', 'id_submission'), coalesce(max(id_submission)+1, 1), false) FROM submissions;
SELECT setval(pg_get_serial_sequence('meetings', 'id_meeting'), coalesce(max(id_meeting)+1, 1), false) FROM meetings;
SELECT setval(pg_get_serial_sequence('announcements', 'id_announcement'), coalesce(max(id_announcement)+1, 1), false) FROM announcements;
SELECT setval(pg_get_serial_sequence('files', 'id_file'), coalesce(max(id_file)+1, 1), false) FROM files;
SELECT setval(pg_get_serial_sequence('notifications', 'id_notification'), coalesce(max(id_notification)+1, 1), false) FROM notifications;
SELECT setval(pg_get_serial_sequence('calendar_events', 'id_event'), coalesce(max(id_event)+1, 1), false) FROM calendar_events;
