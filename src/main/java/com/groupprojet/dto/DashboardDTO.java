package com.groupprojet.dto;

import lombok.Data;
import java.util.List;

@Data
public class DashboardDTO {
    // Common
    private String userName;
    private String role;

    // Student Dashboard
    private Integer totalProjects;
    private Integer activeProjects;
    private Integer completedProjects;
    private Integer totalTasks;
    private Integer totalMilestones;
    private Integer totalSubmissions;
    private Double progress;
    private Double completionRate;
    private Integer tasksTodo;
    private Integer tasksInProgress;
    private Integer tasksDone;
    private Integer overdueTasks;
    private Integer pendingSubmissionsCount;
    private Integer evaluatedSubmissionsCount;
    private List<String> upcomingDeadlines;

    // Admin Dashboard
    private Integer totalUsers;
    private Integer activeUsers;
    private Integer totalMeetings;
    private List<String> recentActivities;

    // Supervisor Dashboard
    private Integer supervisedOrganizations;
    private Integer followedProjects;
    private Integer pendingSubmissions;
    private Integer evaluatedSubmissions;
    private Integer upcomingMeetings;

    // Project Manager Dashboard
    private Integer totalMembers;
    private Integer assignedTasks;
    private String delayedTaskAlert;

    // Kept for backward compatibility if needed elsewhere
    private Integer activeTasks;
    private Integer completedTasks;
    private Double productivityScore;
    private String healthStatus;
}
