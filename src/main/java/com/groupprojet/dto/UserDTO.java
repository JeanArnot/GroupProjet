package com.groupprojet.dto;

import lombok.Data;

@Data
public class UserDTO {
    private Long idUser;
    private String firstName;
    private String lastName;
    private String username;
    private String email;
    private String role;
    private String status;
    private String phone;
    private String university;
    private String speciality;
    private String profileImage;
}
