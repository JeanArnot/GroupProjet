package com.groupprojet.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "meeting_participants")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MeetingParticipant {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idParticipant;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_meeting", referencedColumnName = "idMeeting")
    private Meeting meeting;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_user", referencedColumnName = "idUser")
    private User user;

    @Column(length = 20)
    private String attendanceStatus = "PENDING";
}
