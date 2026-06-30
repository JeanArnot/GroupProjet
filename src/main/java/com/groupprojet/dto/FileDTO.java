package com.groupprojet.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class FileDTO {
    private Long idFile;
    private String name;
    private String originalFileName;
    private String fileUrl;
    private Long size;
    private String type;
    private LocalDateTime uploadDate;
    private Long uploadedById;
    private String uploadedBy;
}
