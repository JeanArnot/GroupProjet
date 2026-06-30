-- Mock Data for OrganizationeProjet Academic Project Management App

-- 1) USERS
-- Assuming pgcrypto is enabled, we use crypt() for passwords, but for simple mock data we'll just insert plain or dummy hashes.
INSERT INTO users (id_user, first_name, last_name, username, email, password, role, phone, university, speciality, bio, status) VALUES
(1, 'Alex', 'Johnson', 'alexj', 'alex.johnson@univ.edu', 'hashed_pass_1', 'ADMIN', '+1234567890', 'Tech University', 'Computer Science', 'Passionate about mobile dev', 'ACTIVE'),
(2, 'Maria', 'Garcia', 'mariag', 'maria.garcia@univ.edu', 'hashed_pass_2', 'LEADER', '+1234567891', 'Tech University', 'Software Engineering', 'UI/UX enthusiast', 'ACTIVE'),
(3, 'David', 'Smith', 'davids', 'david.smith@univ.edu', 'hashed_pass_3', 'MEMBER', '+1234567892', 'Tech University', 'Data Science', 'Data wizard', 'ACTIVE'),
(4, 'Emma', 'Wilson', 'emmaw', 'emma.wilson@univ.edu', 'hashed_pass_4', 'MEMBER', '+1234567893', 'Tech University', 'Information Systems', 'Backend developer', 'ACTIVE'),
(5, 'Lucas', 'Brown', 'lucasb', 'lucas.brown@univ.edu', 'hashed_pass_5', 'MEMBER', '+1234567894', 'Business School', 'Project Management', 'Agile scrum master', 'ACTIVE'),
(6, 'Sophie', 'Martin', 'sophiem', 'sophie.m@univ.edu', 'hashed_pass_6', 'MEMBER', '+1234567895', 'Design Institute', 'Graphic Design', 'Visual communication', 'ACTIVE'),
(7, 'James', 'Taylor', 'jamest', 'james.t@univ.edu', 'hashed_pass_7', 'MEMBER', '+1234567896', 'Tech University', 'Cybersecurity', 'Security first', 'ACTIVE'),
(8, 'Olivia', 'Anderson', 'oliviaa', 'olivia.a@univ.edu', 'hashed_pass_8', 'LEADER', '+1234567897', 'Tech University', 'AI & Robotics', 'AI researcher', 'ACTIVE'),
(9, 'Liam', 'Thomas', 'liamt', 'liam.t@univ.edu', 'hashed_pass_9', 'MEMBER', '+1234567898', 'Business School', 'Marketing', 'Digital marketing', 'ACTIVE'),
(10, 'Chloe', 'White', 'chloew', 'chloe.w@univ.edu', 'hashed_pass_10', 'MEMBER', '+1234567899', 'Tech University', 'Software Engineering', 'Full stack dev', 'ACTIVE');

-- Fix sequence
SELECT setval('users_id_user_seq', 10);

-- 2) OrganizationS
INSERT INTO Organizations (id_Organization, Organization_name, description, created_by, visibility, status) VALUES
(1, 'Alpha Devs', 'Top tier development Organization for mobile apps', 1, 'PUBLIC', 'ACTIVE'),
(2, 'Data Miners', 'Focus on machine learning and data science projects', 3, 'PRIVATE', 'ACTIVE'),
(3, 'Design Thinkers', 'UI/UX and frontend specialists', 6, 'PUBLIC', 'ACTIVE'),
(4, 'Cyber Squad', 'Network and application security task force', 7, 'PRIVATE', 'ACTIVE'),
(5, 'AI Pioneers', 'Researching artificial intelligence algorithms', 8, 'PUBLIC', 'ACTIVE'),
(6, 'Marketing Masters', 'Marketing strategy and business development', 9, 'PUBLIC', 'ACTIVE');

SELECT setval('Organizations_id_Organization_seq', 6);

-- 3) Organization MEMBERS
INSERT INTO Organization_members (id_Organization, id_user, member_role) VALUES
(1, 1, 'LEADER'), (1, 2, 'MEMBER'), (1, 4, 'MEMBER'), (1, 10, 'MEMBER'),
(2, 3, 'LEADER'), (2, 8, 'MEMBER'), (2, 4, 'MEMBER'),
(3, 6, 'LEADER'), (3, 2, 'MEMBER'), (3, 9, 'VIEWER'),
(4, 7, 'LEADER'), (4, 1, 'MEMBER'),
(5, 8, 'LEADER'), (5, 3, 'MEMBER'), (5, 10, 'MEMBER'),
(6, 9, 'LEADER'), (6, 5, 'MEMBER'), (6, 6, 'MEMBER');

-- 4) PROJECTS
INSERT INTO projects (id_project, id_Organization, project_name, description, project_code, status, priority, progress, health_status, estimated_hours, created_by, total_tasks, completed_tasks) VALUES
(1, 1, 'OrganizationeProjet Mobile App', 'Flutter based academic project management app', 'PRJ-001', 'ACTIVE', 'HIGH', 45.5, 'GOOD', 200, 1, 20, 9),
(2, 2, 'Predictive Analytics Engine', 'Python based ML model for student success', 'PRJ-002', 'PLANNING', 'MEDIUM', 10.0, 'GOOD', 150, 3, 10, 1),
(3, 3, 'University Portal Redesign', 'Complete UI overhaul for the main university portal', 'PRJ-003', 'ACTIVE', 'URGENT', 60.0, 'WARNING', 120, 6, 15, 9),
(4, 4, 'Network Vulnerability Scanner', 'Automated security scanning tool', 'PRJ-004', 'ON_HOLD', 'HIGH', 30.0, 'CRITICAL', 80, 7, 12, 3),
(5, 5, 'Chatbot Assistant', 'NLP based assistant for students', 'PRJ-005', 'ACTIVE', 'MEDIUM', 85.0, 'GOOD', 100, 8, 25, 21),
(6, 6, 'Social Media Campaign', 'Campaign for the new CS curriculum', 'PRJ-006', 'COMPLETED', 'LOW', 100.0, 'GOOD', 50, 9, 8, 8);

SELECT setval('projects_id_project_seq', 6);

-- 5) PROJECT MEMBERS
INSERT INTO project_members (id_project, id_user, role_in_project) VALUES
(1, 1, 'LEADER'), (1, 2, 'MEMBER'), (1, 4, 'MEMBER'), (1, 10, 'MEMBER'),
(2, 3, 'LEADER'), (2, 8, 'MEMBER'),
(3, 6, 'LEADER'), (3, 2, 'MEMBER'),
(4, 7, 'LEADER'), (4, 1, 'REVIEWER'),
(5, 8, 'LEADER'), (5, 3, 'MEMBER'), (5, 4, 'MEMBER'),
(6, 9, 'LEADER'), (6, 5, 'MEMBER'), (6, 6, 'REVIEWER');

-- 6) TASKS
INSERT INTO tasks (id_task, id_project, assigned_to, task_title, description, priority, status, progress, estimated_time, spent_time, created_by) VALUES
-- Project 1: Mobile App
(1, 1, 2, 'Design Dashboard UI', 'Create Figma mockups for the dashboard', 'HIGH', 'DONE', 100, 10, 12, 1),
(2, 1, 1, 'Setup Flutter Project', 'Initialize Flutter project and add dependencies', 'HIGH', 'DONE', 100, 5, 4, 1),
(3, 1, 4, 'Database Schema', 'Design PostgreSQL schema for backend', 'URGENT', 'DONE', 100, 8, 8, 1),
(4, 1, 10, 'Implement Auth API', 'Spring Boot endpoints for JWT login', 'HIGH', 'IN_PROGRESS', 50, 15, 10, 1),
(5, 1, 2, 'Develop Organizations Screen', 'Build the Organizations screen in Flutter', 'MEDIUM', 'TODO', 0, 12, 0, 1),
(6, 1, 1, 'Integrate WebSocket', 'Real-time notifications setup', 'HIGH', 'TODO', 0, 20, 0, 1),
-- Project 2: Predictive Analytics
(7, 2, 3, 'Data Collection', 'Gather anonymized student grades data', 'HIGH', 'DONE', 100, 20, 22, 3),
(8, 2, 8, 'Data Cleaning', 'Remove nulls and outliers', 'MEDIUM', 'IN_PROGRESS', 40, 15, 8, 3),
(9, 2, 3, 'Model Selection', 'Evaluate Random Forest vs SVM', 'HIGH', 'TODO', 0, 10, 0, 3),
-- Project 3: Portal Redesign
(10, 3, 6, 'User Research', 'Interview students about portal pain points', 'HIGH', 'DONE', 100, 15, 15, 6),
(11, 3, 2, 'Wireframing', 'Low fidelity wireframes', 'MEDIUM', 'DONE', 100, 10, 9, 6),
(12, 3, 6, 'High Fidelity Design', 'Create final UI in Figma', 'URGENT', 'IN_PROGRESS', 70, 25, 20, 6),
(13, 3, 2, 'Design System Handoff', 'Prepare assets for developers', 'MEDIUM', 'TODO', 0, 8, 0, 6),
-- Project 4: Security
(14, 4, 7, 'Port Scanner Core', 'Write the core scanning logic in Python', 'HIGH', 'IN_PROGRESS', 80, 20, 18, 7),
(15, 4, 1, 'Web Interface', 'Simple dashboard for scan results', 'MEDIUM', 'TODO', 0, 15, 0, 7),
-- Project 5: Chatbot
(16, 5, 8, 'NLP Training', 'Train intent classification model', 'HIGH', 'DONE', 100, 30, 32, 8),
(17, 5, 4, 'Backend Integration', 'Connect model to Spring Boot backend', 'HIGH', 'DONE', 100, 20, 20, 8),
(18, 5, 3, 'Frontend Chat UI', 'Build chat interface', 'MEDIUM', 'IN_PROGRESS', 90, 15, 14, 8),
-- Project 6: Campaign
(19, 6, 9, 'Market Research', 'Analyze target audience', 'MEDIUM', 'DONE', 100, 10, 10, 9),
(20, 6, 5, 'Content Creation', 'Write social media posts', 'HIGH', 'DONE', 100, 15, 14, 9),
(21, 6, 6, 'Graphics Design', 'Create banners and images', 'MEDIUM', 'DONE', 100, 12, 12, 9);

SELECT setval('tasks_id_task_seq', 21);

-- 7) TASK DEPENDENCIES
INSERT INTO task_dependencies (task_id, depends_on_task_id) VALUES
(4, 3), -- Auth API depends on Database Schema
(5, 1), -- Organizations Screen depends on Design
(6, 4), -- WebSocket depends on Auth API
(8, 7), -- Data cleaning depends on collection
(9, 8), -- Model selection depends on cleaning
(11, 10), -- Wireframing depends on user research
(12, 11), -- High fidelity depends on wireframing
(13, 12), -- Handoff depends on High fidelity
(15, 14), -- Web interface depends on Scanner core
(18, 17); -- Chat UI depends on backend integration

-- 8) MILESTONES
INSERT INTO milestones (id_project, milestone_name, description, status, completion_percentage, created_by) VALUES
(1, 'Phase 1: Foundation', 'Database and Basic UI setup complete', 'DONE', 100, 1),
(1, 'Phase 2: Core Features', 'Authentication and Project management working', 'IN_PROGRESS', 40, 1),
(1, 'Phase 3: Real-time', 'Websockets and notifications active', 'PENDING', 0, 1),
(3, 'Research Phase', 'User research and wireframes done', 'DONE', 100, 6),
(3, 'Design Phase', 'High fidelity and design system complete', 'IN_PROGRESS', 60, 6),
(5, 'Beta Release', 'Model trained and backend connected', 'DONE', 100, 8),
(5, 'V1 Launch', 'UI completed and deployed', 'IN_PROGRESS', 90, 8);

-- 9) NOTIFICATIONS
INSERT INTO notifications (id_user, title, message, notification_type, is_read) VALUES
(2, 'Task Assigned', 'You have been assigned to "Develop Organizations Screen"', 'TASK', FALSE),
(1, 'Milestone Reached', 'Phase 1: Foundation is 100% complete', 'PROJECT', TRUE),
(4, 'Dependency Unblocked', 'Database Schema is done, you can start Auth API', 'TASK', FALSE),
(10, 'Added to Organization', 'You were added to Alpha Devs', 'Organization', TRUE),
(6, 'Project Risk Warning', 'Portal Redesign is marked as WARNING', 'SYSTEM', FALSE),
(3, 'Meeting Reminder', 'Data analysis sync in 30 minutes', 'MEETING', FALSE),
(8, 'Task Completed', 'Backend Integration is done', 'TASK', TRUE);

-- 10) COMMENTS
INSERT INTO comments (id_task, id_user, comment_text) VALUES
(1, 2, 'The mockups are uploaded to Figma. Check the link.'),
(1, 1, 'Looks great! Approved.'),
(4, 10, 'I am facing an issue with Spring Security config.'),
(4, 4, 'Let me help you with that, I just pushed a fix.'),
(8, 8, 'Data has too many missing values in the grading column.'),
(12, 6, 'Should we use Material 3 or iOS Human Interface guidelines?'),
(12, 2, 'Let us stick to Material 3 since it is cross-platform Flutter.');

-- 11) FILES
INSERT INTO files (id_task, uploaded_by, file_name, file_url, file_size, file_type) VALUES
(1, 2, 'dashboard_mockup.png', 'https://s3.groupprojet.com/files/dashboard_mockup.png', 1024000, 'image/png'),
(3, 4, 'schema_v1.sql', 'https://s3.groupprojet.com/files/schema_v1.sql', 45000, 'text/plain'),
(7, 3, 'student_grades_raw.csv', 'https://s3.groupprojet.com/files/student_grades_raw.csv', 5000000, 'text/csv'),
(10, 6, 'user_interviews_summary.pdf', 'https://s3.groupprojet.com/files/user_interviews_summary.pdf', 2500000, 'application/pdf'),
(20, 5, 'copywriting_draft.docx', 'https://s3.groupprojet.com/files/copywriting_draft.docx', 120000, 'application/docx');

-- 12) ACTIVITIES
INSERT INTO activities (id_user, id_project, activity_type, description) VALUES
(1, 1, 'PROJECT_CREATED', 'Alex created project "OrganizationeProjet Mobile App"'),
(2, 1, 'TASK_COMPLETED', 'Maria completed "Design Dashboard UI"'),
(4, 1, 'FILE_UPLOADED', 'Emma uploaded "schema_v1.sql"'),
(3, 2, 'PROJECT_CREATED', 'David created project "Predictive Analytics Engine"'),
(6, 3, 'MILESTONE_COMPLETED', 'Sophie completed milestone "Research Phase"'),
(8, 5, 'TASK_COMPLETED', 'Olivia completed "NLP Training"'),
(9, 6, 'PROJECT_COMPLETED', 'Liam marked "Social Media Campaign" as completed');

-- 13) MEETINGS
INSERT INTO meetings (id_meeting, id_project, title, description, meeting_link, meeting_date, duration_minutes, created_by) VALUES
(1, 1, 'Weekly Sync', 'Discuss sprint progress and blockers', 'https://meet.google.com/abc-defg-hij', CURRENT_TIMESTAMP + INTERVAL '1 day', 60, 1),
(2, 1, 'UI/UX Review', 'Review dashboard and Organizations screen design', 'https://zoom.us/j/123456789', CURRENT_TIMESTAMP + INTERVAL '2 hours', 45, 2),
(3, 2, 'Data Cleaning Strategy', 'Discuss handling missing values', 'https://meet.google.com/xyz-uvw-rst', CURRENT_TIMESTAMP + INTERVAL '2 days', 30, 3),
(4, 3, 'Design Handoff', 'Handing over Figma assets to devs', 'https://teams.microsoft.com/l/meetup-join/...', CURRENT_TIMESTAMP + INTERVAL '3 days', 60, 6),
(5, 5, 'Beta Testing Results', 'Review chatbot accuracy', 'https://meet.google.com/qwe-rty-uio', CURRENT_TIMESTAMP - INTERVAL '1 day', 45, 8);

SELECT setval('meetings_id_meeting_seq', 5);

-- 14) MEETING PARTICIPANTS
INSERT INTO meeting_participants (id_meeting, id_user, attendance_status) VALUES
(1, 1, 'PRESENT'), (1, 2, 'PENDING'), (1, 4, 'PENDING'), (1, 10, 'PENDING'),
(2, 1, 'PRESENT'), (2, 2, 'PRESENT'),
(3, 3, 'PENDING'), (3, 8, 'PENDING'),
(4, 6, 'PENDING'), (4, 2, 'PENDING'),
(5, 8, 'PRESENT'), (5, 3, 'PRESENT'), (5, 4, 'ABSENT');

-- 15) TASK HISTORY
INSERT INTO task_history (id_task, changed_by, old_status, new_status, change_description) VALUES
(1, 2, 'TODO', 'IN_PROGRESS', 'Started working on mockups'),
(1, 2, 'IN_PROGRESS', 'REVIEW', 'Uploaded for review'),
(1, 1, 'REVIEW', 'DONE', 'Approved mockups'),
(4, 10, 'TODO', 'IN_PROGRESS', 'Started coding Spring Boot endpoints'),
(8, 8, 'TODO', 'IN_PROGRESS', 'Started writing pandas script for cleaning'),
(12, 6, 'TODO', 'IN_PROGRESS', 'Designing screens in Figma');

-- 16) USER PRODUCTIVITY
INSERT INTO user_productivity (id_user, completed_tasks, late_tasks, total_hours_worked, productivity_score) VALUES
(1, 15, 1, 120, 92.5),
(2, 12, 0, 95, 95.0),
(3, 10, 2, 85, 80.0),
(4, 18, 0, 140, 98.0),
(5, 8, 1, 60, 85.5),
(6, 14, 0, 110, 94.0),
(7, 5, 3, 45, 65.0),
(8, 22, 0, 160, 99.0),
(9, 9, 0, 50, 90.0),
(10, 6, 1, 40, 82.0);
