package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "user_settings")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserSettings {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_setting")
    private Long idSetting;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_user", nullable = false, unique = true)
    private User user;

    @Column(name = "notif_email", nullable = false)
    private Boolean notifEmail = true;

    @Column(name = "notif_push", nullable = false)
    private Boolean notifPush = true;

    @Column(name = "notif_task_assigned", nullable = false)
    private Boolean notifTaskAssigned = true;

    @Column(name = "notif_task_due", nullable = false)
    private Boolean notifTaskDue = true;

    @Column(name = "notif_comment", nullable = false)
    private Boolean notifComment = true;

    @Column(name = "notif_mention", nullable = false)
    private Boolean notifMention = true;

    @Column(name = "notif_project_update", nullable = false)
    private Boolean notifProjectUpdate = true;

    @Column(name = "notif_meeting", nullable = false)
    private Boolean notifMeeting = true;

    @Column(name = "notif_digest_daily", nullable = false)
    private Boolean notifDigestDaily = false;

    @Column(name = "notif_digest_weekly", nullable = false)
    private Boolean notifDigestWeekly = true;

    @Column(nullable = false, length = 20)
    private String theme = "DARK";

    @Column(nullable = false, length = 10)
    private String language = "fr";

    @Column(nullable = false, length = 50)
    private String timezone = "UTC";

    @Column(name = "date_format", nullable = false, length = 20)
    private String dateFormat = "DD/MM/YYYY";

    @Column(name = "time_format", nullable = false, length = 5)
    private String timeFormat = "24H";

    @Column(name = "default_view", nullable = false, length = 20)
    private String defaultView = "DASHBOARD";

    @Column(name = "task_view", nullable = false, length = 20)
    private String taskView = "KANBAN";

    @Column(name = "items_per_page", nullable = false)
    private Integer itemsPerPage = 20;

    @Column(name = "profile_visibility", nullable = false, length = 20)
    private String profileVisibility = "MEMBERS";

    @Column(name = "show_online_status", nullable = false)
    private Boolean showOnlineStatus = true;

    @Column(name = "show_last_seen", nullable = false)
    private Boolean showLastSeen = true;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
}
