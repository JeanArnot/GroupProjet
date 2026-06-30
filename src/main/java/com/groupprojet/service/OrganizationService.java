package com.groupprojet.service;

import com.groupprojet.entity.Organization;
import com.groupprojet.repository.OrganizationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class OrganizationService {
    private final OrganizationRepository OrganizationRepository;

    public List<Organization> getAllOrganizations() {
        return OrganizationRepository.findAll();
    }
    
    public Organization createOrganization(Organization Organization) {
        return OrganizationRepository.save(Organization);
    }
}
