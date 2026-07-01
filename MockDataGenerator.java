import java.io.FileWriter;
import java.io.PrintWriter;

public class MockDataGenerator {
    public static void main(String[] args) throws Exception {
        String hash = "$2a$10$vI8aWNnTAQQE5u2nEWeK8.384F9AOn1xQ4r0R15TfJgT/t.wZ/4v2"; // password123
        try (PrintWriter out = new PrintWriter(
                new FileWriter("backend/src/main/resources/db/migration/V9__insert_comprehensive_mock_data.sql"))) {
            out.println("-- Comprehensive Mock Data");

            out.println("INSERT INTO users (first_name, last_name, username, email, password, role) VALUES ");
            for (int i = 1; i <= 8; i++) {
                String role = (i == 1) ? "ADMIN" : "MEMBRE";
                String email = (i == 1) ? "admin@gmail.com"
                        : (i == 2) ? "admin1@gmail.com" : (i == 3) ? "rakoto@gmail.com" : "user" + i + "@gmail.com";
                out.printf("('First%d', 'Last%d', 'user%d', '%s', '%s', '%s')%s\n", i, i, i, email, hash, role,
                        (i == 8) ? ";" : ",");
            }

            out.println("INSERT INTO Organizations (Organization_name, description, created_by) VALUES ");
            for (int i = 1; i <= 8; i++) {
                out.printf("('Organization %d', 'Desc %d', 1)%s\n", i, i, (i == 8) ? ";" : ",");
            }

            out.println("INSERT INTO Organization_members (id_Organization, id_user, member_role) VALUES ");
            for (int i = 1; i <= 8; i++) {
                out.printf("(%d, %d, 'ADMIN')%s\n", i, i, (i == 8) ? ";" : ",");
            }

            out.println(
                    "INSERT INTO projects (id_Organization, project_name, description, status, created_by) VALUES ");
            for (int i = 1; i <= 8; i++) {
                out.printf("(%d, 'Project %d', 'Desc %d', 'ACTIVE', 1)%s\n", i, i, i, (i == 8) ? ";" : ",");
            }

            out.println("INSERT INTO project_members (id_project, id_user, role_in_project) VALUES ");
            for (int i = 1; i <= 8; i++) {
                out.printf("(%d, %d, 'CHEF_PROJET')%s\n", i, i, (i == 8) ? ";" : ",");
            }

            out.println("INSERT INTO tasks (id_project, assigned_to, task_title, description, created_by) VALUES ");
            for (int i = 1; i <= 8; i++) {
                out.printf("(%d, %d, 'Task %d', 'Desc %d', 1)%s\n", i, i, i, i, (i == 8) ? ";" : ",");
            }

            out.println("INSERT INTO milestones (id_project, milestone_title, due_date, created_by) VALUES ");
            for (int i = 1; i <= 8; i++) {
                out.printf("(%d, 'Milestone %d', '2026-12-31', 1)%s\n", i, i, (i == 8) ? ";" : ",");
            }
        }
    }
}
