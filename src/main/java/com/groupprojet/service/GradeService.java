package com.groupprojet.service;

import com.groupprojet.entity.Submission;
import com.groupprojet.repository.SubmissionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class GradeService {

    private final SubmissionRepository submissionRepository;

    public Map<String, Object> getGradesSummaryForUser(Long userId) {
        List<Submission> userSubmissions = submissionRepository.findBySubmittedByIdUser(userId);

        Map<String, Object> response = new HashMap<>();
        List<Map<String, Object>> evaluations = new ArrayList<>();

        BigDecimal totalGrade = BigDecimal.ZERO;
        int evaluatedCount = 0;

        String feedback = "Pas d'évaluations récentes.";

        for (Submission s : userSubmissions) {
            Map<String, Object> eval = new HashMap<>();

            String title = "Soumission";
            if (s.getSubmissionNote() != null && !s.getSubmissionNote().isEmpty()) {
                title = s.getSubmissionNote();
            } else if (s.getTask() != null) {
                title = s.getTask().getTaskTitle();
            } else if (s.getMilestone() != null) {
                title = s.getMilestone().getMilestoneName();
            }

            eval.put("title", title);

            if (s.getGrade() != null) {
                eval.put("score", s.getGrade().toString());
                eval.put("isEvaluated", true);
                totalGrade = totalGrade.add(s.getGrade());
                evaluatedCount++;

                if (s.getFeedback() != null && !s.getFeedback().isEmpty()) {
                    feedback = s.getFeedback(); // Use the latest feedback
                }
            } else {
                eval.put("score", "-");
                eval.put("isEvaluated", false);
            }

            evaluations.add(eval);
        }

        response.put("evaluations", evaluations);

        if (evaluatedCount > 0) {
            BigDecimal average = totalGrade.divide(BigDecimal.valueOf(evaluatedCount), 1, RoundingMode.HALF_UP);
            response.put("finalGrade", average.toString());
            response.put("gradeLetter", getGradeLetter(average));
        } else {
            response.put("finalGrade", "-");
            response.put("gradeLetter", "-");
        }

        response.put("feedback", feedback);

        return response;
    }

    private String getGradeLetter(BigDecimal grade) {
        double val = grade.doubleValue();
        if (val >= 18)
            return "A+";
        if (val >= 16)
            return "A";
        if (val >= 14)
            return "A-";
        if (val >= 12)
            return "B";
        if (val >= 10)
            return "C";
        if (val >= 8)
            return "D";
        return "F";
    }
}
