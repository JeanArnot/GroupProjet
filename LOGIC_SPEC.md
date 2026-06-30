# GroupeProjet - Backend & Application Logic Specification

This document outlines the core business logic, features, and system rules required for the **GroupeProjet** academic project management app.

## 1. Authentication & Roles
- **System**: JWT based login/registration.
- **Roles**: `ADMIN`, `LEADER`, `MEMBER`.
- **Permissions**:
  - `ADMIN` and `LEADER` can create/edit projects, add members, and manage settings.
  - `MEMBER` can view details, work on assigned tasks, and add comments.

## 2. Group Management
- Users can create groups, add/remove members, and assign roles within the group.
- An `access_code` supports invite-based joining, tailored for academic team setups.

## 3. Project Management
- One group has multiple projects.
- Projects track `status`, `priority`, `progress` (0-100), `health_status`, and target dates.

## 4. Task Management (The Core)
- Full CRUD for tasks: assignment, deadline, priority, status, progress, attachments, comments, and history.
- One project has multiple tasks. One task has one or zero assignees.

## 5. Milestones
- High-level checkpoints (e.g., "Analysis Complete", "Design Approved").
- Auto-completes to "DONE" when all linked tasks reach completion.

---

## Advanced Professional Features

### 6. Task Dependencies
- A task cannot move to `IN_PROGRESS` if a prerequisite dependency is not `DONE`.
- Blocked tasks trigger visual indicators in the frontend and automatic system notifications.

### 7. Project Health Score
- **Calculated automatically**: Evaluates if the project is `GOOD`, `WARNING`, or `CRITICAL`.
- Logic looks at the ratio of completed tasks, overdue tasks, and looming deadlines versus the current date.

### 8. Productivity Analytics
- Tracks `completed_tasks`, `late_tasks`, and `total_hours_worked`.
- Calculates a `productivity_score` for the Dashboard to motivate students.

### 9. Smart Notifications (WebSocket)
- Beyond simple alerts: Triggers on new assignments, impending deadlines, overdue tasks, and meeting starts.
- Backend uses Spring Boot WebSockets for real-time delivery to the Flutter frontend.

### 10. Meetings & Participants
- Tracks meetings, links (Zoom/Meet), and participant attendance (`PRESENT`, `ABSENT`, `LATE`).

---

## Core System Automations (Database & Service Layer)

1. **Automatic Progress Recalculation**: 
   When a task status changes to `DONE`, the backend service recalculates the parent project's `progress` percentage (e.g., 8 out of 10 tasks = 80%).
2. **Deadline Logic**: 
   A scheduled CRON job or service checks tasks. If `deadline < NOW()` and status is not `DONE`, status becomes `OVERDUE` (or `is_blocked = true`).
3. **Validation & Integrity**:
   - DTO validation via `@Valid` annotations in Spring Boot.
   - Database level `CHECK` constraints (already applied).
   - PostgreSQL `updated_at` automated via triggers.
