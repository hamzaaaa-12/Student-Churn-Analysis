use Student_Churn



/*==========================================================
  Load FACT_ASSESSMENT_SUBMISSION
==========================================================*/

TRUNCATE TABLE engagement_dw.fact_assessment_submission;
GO

INSERT INTO engagement_dw.fact_assessment_submission
(
    student_key,
    course_key,
    assessment_key,
    score,
    is_banked
)

SELECT

    ds.student_key,

    dc.course_key,

    da.assessment_key,

    sa.score,

    CAST(sa.is_banked AS BIT)

FROM engagement_clean.studentAssessment sa

INNER JOIN engagement_clean.assessments a
    ON sa.id_assessment = a.id_assessment

INNER JOIN engagement_dw.dim_student ds
    ON sa.id_student = ds.id_student

INNER JOIN engagement_dw.dim_course dc
    ON a.code_module = dc.code_module
   AND a.code_presentation = dc.code_presentation

INNER JOIN engagement_dw.dim_assessment da
    ON sa.id_assessment = da.id_assessment;
GO

SELECT COUNT(*)
FROM engagement_dw.fact_assessment_submission;

SELECT TOP (10) *
FROM engagement_dw.fact_assessment_submission;