package com.groupprojet.dto;

import lombok.Data;

@Data
public class SocialAuthRequestDTO {
    private String provider;
    private String providerId;
    private String email;
    private String firstName;
    private String lastName;
    private String profileImage;
}
