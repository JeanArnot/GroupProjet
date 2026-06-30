package com.groupprojet.service;

import com.groupprojet.entity.Supervisor;
import com.groupprojet.repository.SupervisorRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class SupervisorService {

    private final SupervisorRepository supervisorRepository;

    public List<Supervisor> getAllSupervisors() {
        return supervisorRepository.findAll();
    }

    public Optional<Supervisor> getSupervisorById(Long id) {
        return supervisorRepository.findById(id);
    }

    public Optional<Supervisor> getSupervisorByUserId(Long userId) {
        return supervisorRepository.findByUserIdUser(userId);
    }

    @Transactional
    public Supervisor createSupervisor(Supervisor supervisor) {
        return supervisorRepository.save(supervisor);
    }

    @Transactional
    public void deleteSupervisor(Long id) {
        supervisorRepository.deleteById(id);
    }
}
