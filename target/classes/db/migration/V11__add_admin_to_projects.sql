-- V11: Add the global admin (id_user=1) to a few projects so they can create tasks
INSERT INTO project_members (id_project, id_user, role_in_project)
SELECT id_project, 1, 'CHEF_PROJET'
FROM projects
WHERE id_project IN (1, 2)
ON CONFLICT (id_project, id_user) DO NOTHING;
