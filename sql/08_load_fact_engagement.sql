use Student_Churn


/*==========================================================
  Load FACT_ENGAGEMENT_DAILY
==========================================================*/

TRUNCATE TABLE engagement_dw.fact_engagement_daily;
GO


INSERT INTO engagement_dw.fact_engagement_daily
(
    student_key,
    course_key,
    course_date_key,
    activity_key,
    sum_click,
    activity_count
)

SELECT

    ds.student_key,

    dc.course_key,

    dd.date_key,

    dat.activity_key,

    SUM(sv.sum_click) AS sum_click,

    COUNT(*) AS activity_count

FROM engagement_clean.studentVle sv

INNER JOIN engagement_dw.dim_student ds
    ON sv.id_student = ds.id_student

INNER JOIN engagement_dw.dim_course dc
    ON sv.code_module = dc.code_module
   AND sv.code_presentation = dc.code_presentation

INNER JOIN engagement_dw.dim_date dd
    ON sv.date = dd.course_day

INNER JOIN engagement_dw.dim_activity_type dat
    ON sv.id_site = dat.id_site

GROUP BY

    ds.student_key,

    dc.course_key,

    dd.date_key,

    dat.activity_key;
GO

SELECT COUNT(*)
FROM engagement_dw.fact_engagement_daily;

SELECT TOP (10) *
FROM engagement_dw.fact_engagement_daily
ORDER BY student_key;