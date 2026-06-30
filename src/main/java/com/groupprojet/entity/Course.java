package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "courses")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Course {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_course")
    private Long idCourse;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_academic_year")
    private AcademicYear academicYear;

    @Column(name = "course_name", nullable = false, length = 200)
    private String courseName;

    @Column(name = "course_code", unique = true, length = 50)
    private String courseCode;

    @Column(columnDefinition = "TEXT")
    private String description;

    private Integer credits;

    @Column(length = 150)
    private String university;

    @Column(length = 150)
    private String department;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
}
