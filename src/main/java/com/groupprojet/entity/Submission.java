package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "submissions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Submission {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id_submission")
  private Long idSubmission;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "id_project", nullable = false)
  private Project project;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "id_task")
  private Task task;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "id_milestone")
  private Milestone milestone;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "submitted_by", nullable = false)
  private User submittedBy;

  @Column(name = "submission_title", nullable = false, length = 200)
  private String submissionTitle;

  @Column(name = "submission_note", columnDefinition = "TEXT")
  private String submissionNote;

  @org.hibernate.annotations.Type(io.hypersistence.utils.hibernate.type.array.ListArrayType.class)
  @Column(name = "file_urls", columnDefinition = "text[]")
  private java.util.List<String> fileUrls;

  @Column(nullable = false, length = 20)
  private String status = "PENDING";

  @Column(precision = 5, scale = 2)
  private java.math.BigDecimal grade;

  @Column(columnDefinition = "TEXT")
  private String feedback;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "evaluated_by")
  private User evaluatedBy;

  @Column(name = "evaluated_at")
  private LocalDateTime evaluatedAt;

  @Column(name = "due_date")
  private LocalDateTime dueDate;

  @CreationTimestamp
  @Column(name = "submitted_at", nullable = false, updatable = false)
  private LocalDateTime submittedAt;

  @Column(name = "is_late", nullable = false)
  private Boolean isLate = false;

  @Column(name = "late_hours")
  private Integer lateDurationHours;
}
