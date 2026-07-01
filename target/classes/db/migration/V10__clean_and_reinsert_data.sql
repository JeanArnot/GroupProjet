-- Comprehensive Mock Data
TRUNCATE TABLE users, Organizations, Organization_members, projects, project_members, tasks, milestones CASCADE;

INSERT INTO users (first_name, last_name, username, email, password, role) VALUES 
('First1', 'Last1', 'user1', 'admin@gmail.com', '$2a$10$vI8aWNnTAQQE5u2nEWeK8.384F9AOn1xQ4r0R15TfJgT/t.wZ/4v2', 'ADMIN'),
('First2', 'Last2', 'user2', 'admin1@gmail.com', '$2a$10$vI8aWNnTAQQE5u2nEWeK8.384F9AOn1xQ4r0R15TfJgT/t.wZ/4v2', 'MEMBRE'),
('First3', 'Last3', 'user3', 'rakoto@gmail.com', '$2a$10$vI8aWNnTAQQE5u2nEWeK8.384F9AOn1xQ4r0R15TfJgT/t.wZ/4v2', 'MEMBRE'),
('First4', 'Last4', 'user4', 'user4@gmail.com', '$2a$10$vI8aWNnTAQQE5u2nEWeK8.384F9AOn1xQ4r0R15TfJgT/t.wZ/4v2', 'MEMBRE'),
('First5', 'Last5', 'user5', 'user5@gmail.com', '$2a$10$vI8aWNnTAQQE5u2nEWeK8.384F9AOn1xQ4r0R15TfJgT/t.wZ/4v2', 'MEMBRE'),
('First6', 'Last6', 'user6', 'user6@gmail.com', '$2a$10$vI8aWNnTAQQE5u2nEWeK8.384F9AOn1xQ4r0R15TfJgT/t.wZ/4v2', 'MEMBRE'),
('First7', 'Last7', 'user7', 'user7@gmail.com', '$2a$10$vI8aWNnTAQQE5u2nEWeK8.384F9AOn1xQ4r0R15TfJgT/t.wZ/4v2', 'MEMBRE'),
('First8', 'Last8', 'user8', 'user8@gmail.com', '$2a$10$vI8aWNnTAQQE5u2nEWeK8.384F9AOn1xQ4r0R15TfJgT/t.wZ/4v2', 'MEMBRE');
INSERT INTO Organizations (Organization_name, description, created_by) VALUES 
('Organization 1', 'Desc 1', 1),
('Organization 2', 'Desc 2', 1),
('Organization 3', 'Desc 3', 1),
('Organization 4', 'Desc 4', 1),
('Organization 5', 'Desc 5', 1),
('Organization 6', 'Desc 6', 1),
('Organization 7', 'Desc 7', 1),
('Organization 8', 'Desc 8', 1);
INSERT INTO Organization_members (id_Organization, id_user, member_role) VALUES 
(1, 1, 'ADMIN'),
(2, 2, 'ADMIN'),
(3, 3, 'ADMIN'),
(4, 4, 'ADMIN'),
(5, 5, 'ADMIN'),
(6, 6, 'ADMIN'),
(7, 7, 'ADMIN'),
(8, 8, 'ADMIN');
INSERT INTO projects (id_Organization, project_name, description, status, created_by) VALUES 
(1, 'Project 1', 'Desc 1', 'ACTIVE', 1),
(2, 'Project 2', 'Desc 2', 'ACTIVE', 1),
(3, 'Project 3', 'Desc 3', 'ACTIVE', 1),
(4, 'Project 4', 'Desc 4', 'ACTIVE', 1),
(5, 'Project 5', 'Desc 5', 'ACTIVE', 1),
(6, 'Project 6', 'Desc 6', 'ACTIVE', 1),
(7, 'Project 7', 'Desc 7', 'ACTIVE', 1),
(8, 'Project 8', 'Desc 8', 'ACTIVE', 1);
INSERT INTO project_members (id_project, id_user, role_in_project) VALUES 
(1, 1, 'CHEF_PROJET'),
(2, 2, 'CHEF_PROJET'),
(3, 3, 'CHEF_PROJET'),
(4, 4, 'CHEF_PROJET'),
(5, 5, 'CHEF_PROJET'),
(6, 6, 'CHEF_PROJET'),
(7, 7, 'CHEF_PROJET'),
(8, 8, 'CHEF_PROJET');
INSERT INTO tasks (id_project, assigned_to, task_title, description, created_by) VALUES 
(1, 1, 'Task 1', 'Desc 1', 1),
(2, 2, 'Task 2', 'Desc 2', 1),
(3, 3, 'Task 3', 'Desc 3', 1),
(4, 4, 'Task 4', 'Desc 4', 1),
(5, 5, 'Task 5', 'Desc 5', 1),
(6, 6, 'Task 6', 'Desc 6', 1),
(7, 7, 'Task 7', 'Desc 7', 1),
(8, 8, 'Task 8', 'Desc 8', 1);
INSERT INTO milestones (id_project, milestone_title, due_date, created_by) VALUES 
(1, 'Milestone 1', '2026-12-31', 1),
(2, 'Milestone 2', '2026-12-31', 1),
(3, 'Milestone 3', '2026-12-31', 1),
(4, 'Milestone 4', '2026-12-31', 1),
(5, 'Milestone 5', '2026-12-31', 1),
(6, 'Milestone 6', '2026-12-31', 1),
(7, 'Milestone 7', '2026-12-31', 1),
(8, 'Milestone 8', '2026-12-31', 1);
