package com.groupprojet.service;

import com.groupprojet.dto.DashboardDTO;
import com.groupprojet.entity.Activity;
import com.groupprojet.entity.Meeting;
import com.groupprojet.entity.Milestone;
import com.groupprojet.entity.Project;
import com.groupprojet.entity.ProjectMember;
import com.groupprojet.entity.Submission;
import com.groupprojet.entity.Task;
import com.groupprojet.entity.User;
import com.groupprojet.repository.ActivityRepository;
import com.groupprojet.repository.OrganizationRepository;
import com.groupprojet.repository.MeetingRepository;
import com.groupprojet.repository.MilestoneRepository;
import com.groupprojet.repository.ProjectMemberRepository;
import com.groupprojet.repository.ProjectRepository;
import com.groupprojet.repository.SubmissionRepository;
import com.groupprojet.repository.TaskRepository;
import com.groupprojet.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final ProjectRepository projectRepository;
    private final TaskRepository taskRepository;
    private final UserRepository userRepository;
    private final MilestoneRepository milestoneRepository;
    private final SubmissionRepository submissionRepository;
    private final MeetingRepository meetingRepository;
    private final ProjectMemberRepository projectMemberRepository;
    private final OrganizationRepository OrganizationRepository;
    private final ActivityRepository activityRepository;

    public DashboardDTO getDashboardStats(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        DashboardDTO dashboard = new DashboardDTO();
        dashboard.setUserName(user.getFirstName() != null ? user.getFirstName() : user.getUsername());
        dashboard.setRole(user.getRole() != null ? user.getRole() : "ETUDIANT");

        if ("ADMIN".equalsIgnoreCase(user.getRole())) {
            populateAdminDashboard(dashboard);
        } else if ("ENCADREUR".equalsIgnoreCase(user.getRole()) || "SUPERVISOR".equalsIgnoreCase(user.getRole())) {
            populateSupervisorDashboard(dashboard, userId);
        } else if ("CHEF_PROJET".equalsIgnoreCase(user.getRole()) || "PM".equalsIgnoreCase(user.getRole())) {
            populatePmDashboard(dashboard, userId);
        } else {
            populateStudentDashboard(dashboard, userId);
        }

        return dashboard;
    }

    private void populateStudentDashboard(DashboardDTO dashboard, Long userId) {
        List<Project> projects = getProjectsForUser(userId);
        List<Task> tasks = taskRepository.findByAssignedToIdUser(userId);
        List<Milestone> milestones = getMilestonesForProjects(projects);
        List<Submission> submissions = submissionRepository.findBySubmittedByIdUser(userId);

        fillProjectStats(dashboard, projects);
        fillTaskStats(dashboard, tasks);
        fillSubmissionStats(dashboard, submissions);
        dashboard.setTotalMilestones(milestones.size());
        dashboard.setProductivityScore(round(nullToZero(dashboard.getCompletionRate()) / 10.0, 2));
        dashboard.setHealthStatus(resolveHealthStatus(dashboard.getOverdueTasks(), dashboard.getProgress()));
        dashboard.setUpcomingDeadlines(buildUpcomingDeadlines(tasks, milestones, meetingRepository.findByCreatedByIdUser(userId)));
        dashboard.setRecentActivities(buildRecentActivities(userId, projects));
    }

    private void populateAdminDashboard(DashboardDTO dashboard) {
        List<Project> projects = projectRepository.findAll();
        List<Task> tasks = taskRepository.findAll();
        List<Submission> submissions = submissionRepository.findAll();

        dashboard.setTotalUsers((int) userRepository.count());
        dashboard.setActiveUsers((int) userRepository.findAll().stream()
                .filter(user -> !"INACTIVE".equalsIgnoreCase(empty(user.getStatus())))
                .count());
        dashboard.setTotalMeetings((int) meetingRepository.count());
        fillProjectStats(dashboard, projects);
        fillTaskStats(dashboard, tasks);
        fillSubmissionStats(dashboard, submissions);
        dashboard.setTotalMilestones((int) milestoneRepository.count());
        dashboard.setHealthStatus(resolveHealthStatus(dashboard.getOverdueTasks(), dashboard.getProgress()));
        dashboard.setRecentActivities(activityRepository.findAll().stream()
                .sorted(Comparator.comparing(Activity::getCreatedAt, Comparator.nullsLast(Comparator.naturalOrder())).reversed())
                .limit(5)
                .map(activity -> defaultText(activity.getDescription(), defaultText(activity.getActivityType(), "Activite systeme")))
                .collect(Collectors.toList()));
    }

    private void populateSupervisorDashboard(DashboardDTO dashboard, Long userId) {
        List<Project> projects = getProjectsForUser(userId);
        List<Long> projectIds = projectIds(projects);
        List<Task> tasks = tasksForProjects(projectIds);
        List<Submission> submissions = submissionsForProjects(projectIds);
        List<Milestone> milestones = getMilestonesForProjects(projects);

        dashboard.setSupervisedOrganizations((int) OrganizationRepository.findAll().stream()
                .filter(Organization -> Organization.getCreatedBy() != null && userId.equals(Organization.getCreatedBy().getIdUser()))
                .count());
        dashboard.setFollowedProjects(projects.size());
        dashboard.setPendingSubmissions((int) submissions.stream().filter(this::isPendingSubmission).count());
        dashboard.setEvaluatedSubmissions((int) submissions.stream().filter(this::isEvaluatedSubmission).count());
        dashboard.setUpcomingMeetings((int) meetingRepository.findByCreatedByIdUser(userId).stream()
                .filter(meeting -> meeting.getMeetingDate() != null && !meeting.getMeetingDate().isBefore(LocalDateTime.now()))
                .count());

        fillProjectStats(dashboard, projects);
        fillTaskStats(dashboard, tasks);
        fillSubmissionStats(dashboard, submissions);
        dashboard.setTotalMilestones(milestones.size());
        dashboard.setHealthStatus(resolveHealthStatus(dashboard.getOverdueTasks(), dashboard.getProgress()));
        dashboard.setUpcomingDeadlines(buildUpcomingDeadlines(tasks, milestones, meetingRepository.findByCreatedByIdUser(userId)));
        dashboard.setRecentActivities(buildRecentActivities(userId, projects));
    }

    private void populatePmDashboard(DashboardDTO dashboard, Long userId) {
        List<Project> projects = getProjectsForUser(userId);
        List<Long> projectIds = projectIds(projects);
        List<Task> projectTasks = tasksForProjects(projectIds);
        List<Task> assignedTasks = taskRepository.findByAssignedToIdUser(userId);
        List<Milestone> milestones = getMilestonesForProjects(projects);
        List<Submission> submissions = submissionsForProjects(projectIds);

        dashboard.setTotalMembers((int) projectMemberRepository.findAll().stream()
                .filter(member -> member.getProject() != null && projectIds.contains(member.getProject().getIdProject()))
                .map(member -> member.getUser() != null ? member.getUser().getIdUser() : null)
                .filter(id -> id != null)
                .distinct()
                .count());
        dashboard.setAssignedTasks(assignedTasks.size());
        dashboard.setDelayedTaskAlert(buildDelayedTaskAlert(projectTasks));

        fillProjectStats(dashboard, projects);
        fillTaskStats(dashboard, projectTasks);
        fillSubmissionStats(dashboard, submissions);
        dashboard.setTotalMilestones(milestones.size());
        dashboard.setHealthStatus(resolveHealthStatus(dashboard.getOverdueTasks(), dashboard.getProgress()));
        dashboard.setUpcomingDeadlines(buildUpcomingDeadlines(projectTasks, milestones, meetingRepository.findByCreatedByIdUser(userId)));
        dashboard.setRecentActivities(buildRecentActivities(userId, projects));
    }

    private void fillProjectStats(DashboardDTO dashboard, List<Project> projects) {
        dashboard.setTotalProjects(projects.size());
        dashboard.setActiveProjects((int) projects.stream().filter(this::isActiveProject).count());
        dashboard.setCompletedProjects((int) projects.stream().filter(this::isCompletedProject).count());
    }

    private void fillTaskStats(DashboardDTO dashboard, List<Task> tasks) {
        long todo = tasks.stream().filter(task -> "TODO".equalsIgnoreCase(empty(task.getStatus()))
                || "PENDING".equalsIgnoreCase(empty(task.getStatus()))).count();
        long inProgress = tasks.stream().filter(task -> "IN_PROGRESS".equalsIgnoreCase(empty(task.getStatus()))).count();
        long done = tasks.stream().filter(this::isDoneTask).count();

        dashboard.setTotalTasks(tasks.size());
        dashboard.setTasksTodo((int) todo);
        dashboard.setTasksInProgress((int) inProgress);
        dashboard.setTasksDone((int) done);
        dashboard.setOverdueTasks((int) tasks.stream().filter(this::isOverdueTask).count());
        dashboard.setActiveTasks((int) (todo + inProgress));
        dashboard.setCompletedTasks((int) done);

        double progress = tasks.isEmpty() ? 0.0 : (double) done / tasks.size();
        dashboard.setProgress(round(progress, 4));
        dashboard.setCompletionRate(round(progress * 100.0, 2));
    }

    private void fillSubmissionStats(DashboardDTO dashboard, List<Submission> submissions) {
        dashboard.setTotalSubmissions(submissions.size());
        dashboard.setPendingSubmissionsCount((int) submissions.stream().filter(this::isPendingSubmission).count());
        dashboard.setEvaluatedSubmissionsCount((int) submissions.stream().filter(this::isEvaluatedSubmission).count());
    }

    private List<Project> getProjectsForUser(Long userId) {
        Map<Long, Project> projects = new LinkedHashMap<>();
        projectRepository.findByCreatedByIdUser(userId).forEach(project -> projects.put(project.getIdProject(), project));
        projectMemberRepository.findByUserIdUser(userId).stream()
                .map(ProjectMember::getProject)
                .filter(project -> project != null)
                .forEach(project -> projects.put(project.getIdProject(), project));
        return new ArrayList<>(projects.values());
    }

    private List<Long> projectIds(List<Project> projects) {
        return projects.stream().map(Project::getIdProject).toList();
    }

    private List<Task> tasksForProjects(List<Long> projectIds) {
        return taskRepository.findAll().stream()
                .filter(task -> task.getProject() != null && projectIds.contains(task.getProject().getIdProject()))
                .toList();
    }

    private List<Submission> submissionsForProjects(List<Long> projectIds) {
        return submissionRepository.findAll().stream()
                .filter(submission -> submission.getProject() != null && projectIds.contains(submission.getProject().getIdProject()))
                .toList();
    }

    private List<Milestone> getMilestonesForProjects(List<Project> projects) {
        return projects.stream()
                .flatMap(project -> milestoneRepository.findByProjectIdProject(project.getIdProject()).stream())
                .toList();
    }

    private List<String> buildUpcomingDeadlines(List<Task> tasks, List<Milestone> milestones, List<Meeting> meetings) {
        List<String> items = new ArrayList<>();
        tasks.stream()
                .filter(task -> task.getDeadline() != null && !isDoneTask(task))
                .sorted(Comparator.comparing(Task::getDeadline))
                .limit(3)
                .forEach(task -> items.add("Tache: " + defaultText(task.getTaskTitle(), "Sans titre") + " - " + task.getDeadline().toLocalDate()));
        milestones.stream()
                .filter(milestone -> milestone.getDueDate() != null && !isCompletedStatus(milestone.getStatus()))
                .sorted(Comparator.comparing(Milestone::getDueDate))
                .limit(2)
                .forEach(milestone -> items.add("Jalon: " + defaultText(milestone.getMilestoneName(), "Sans titre") + " - " + milestone.getDueDate()));
        meetings.stream()
                .filter(meeting -> meeting.getMeetingDate() != null && !meeting.getMeetingDate().isBefore(LocalDateTime.now()))
                .sorted(Comparator.comparing(Meeting::getMeetingDate))
                .limit(2)
                .forEach(meeting -> items.add("Reunion: " + defaultText(meeting.getTitle(), "Sans titre") + " - " + meeting.getMeetingDate()));
        return items.stream().limit(5).toList();
    }

    private List<String> buildRecentActivities(Long userId, List<Project> projects) {
        List<Long> ids = projectIds(projects);
        List<String> activities = activityRepository.findAll().stream()
                .filter(activity -> (activity.getUser() != null && userId.equals(activity.getUser().getIdUser()))
                        || (activity.getProject() != null && ids.contains(activity.getProject().getIdProject())))
                .sorted(Comparator.comparing(Activity::getCreatedAt, Comparator.nullsLast(Comparator.naturalOrder())).reversed())
                .limit(5)
                .map(activity -> defaultText(activity.getDescription(), defaultText(activity.getActivityType(), "Activite recente")))
                .collect(Collectors.toList());
        if (!activities.isEmpty()) {
            return activities;
        }
        return projects.stream()
                .sorted(Comparator.comparing(Project::getUpdatedAt, Comparator.nullsLast(Comparator.naturalOrder())).reversed())
                .limit(3)
                .map(project -> "Projet: " + defaultText(project.getProjectName(), "Sans nom") + " - " + defaultText(project.getStatus(), "PLANNING"))
                .collect(Collectors.toList());
    }

    private String buildDelayedTaskAlert(List<Task> tasks) {
        return tasks.stream()
                .filter(this::isOverdueTask)
                .sorted(Comparator.comparing(Task::getDeadline, Comparator.nullsLast(Comparator.naturalOrder())))
                .findFirst()
                .map(task -> "Tache en retard: " + defaultText(task.getTaskTitle(), "Sans titre"))
                .orElse("Aucun retard detecte");
    }

    private boolean isDoneTask(Task task) {
        return isCompletedStatus(task.getStatus());
    }

    private boolean isOverdueTask(Task task) {
        return task.getDeadline() != null && task.getDeadline().isBefore(LocalDateTime.now()) && !isDoneTask(task);
    }

    private boolean isPendingSubmission(Submission submission) {
        String status = empty(submission.getStatus());
        return status.isBlank() || "PENDING".equalsIgnoreCase(status) || "SUBMITTED".equalsIgnoreCase(status);
    }

    private boolean isEvaluatedSubmission(Submission submission) {
        String status = empty(submission.getStatus());
        return "EVALUATED".equalsIgnoreCase(status) || "GRADED".equalsIgnoreCase(status);
    }

    private boolean isActiveProject(Project project) {
        String status = empty(project.getStatus());
        return !Boolean.TRUE.equals(project.getArchived()) && !"ARCHIVED".equalsIgnoreCase(status) && !isCompletedStatus(status);
    }

    private boolean isCompletedProject(Project project) {
        return isCompletedStatus(project.getStatus());
    }

    private boolean isCompletedStatus(String status) {
        return "DONE".equalsIgnoreCase(empty(status)) || "COMPLETED".equalsIgnoreCase(empty(status));
    }

    private String resolveHealthStatus(Integer overdueTasks, Double progress) {
        if (overdueTasks != null && overdueTasks > 0) {
            return "NEEDS_ATTENTION";
        }
        return progress != null && progress >= 0.7 ? "GOOD" : "ON_TRACK";
    }

    private String empty(String value) {
        return value == null ? "" : value;
    }

    private String defaultText(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value;
    }

    private double nullToZero(Double value) {
        return value == null ? 0.0 : value;
    }

    private double round(double value, int places) {
        double scale = Math.pow(10, places);
        return Math.round(value * scale) / scale;
    }
}
