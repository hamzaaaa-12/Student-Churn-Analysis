USE Student_Churn;
GO

IF OBJECT_ID('engagement_dw.vw_student_risk','V') IS NOT NULL
    DROP VIEW engagement_dw.vw_student_risk;
GO

CREATE VIEW engagement_dw.vw_student_risk
AS

WITH EngagementSummary AS
(
    SELECT

        student_key,

        course_key,

        SUM(sum_click) AS total_clicks,

        SUM(activity_count) AS total_activities

    FROM engagement_dw.fact_engagement_daily

    GROUP BY

        student_key,

        course_key
),

AssessmentSummary AS
(
    SELECT

        student_key,

        course_key,

        AVG(CAST(score AS FLOAT)) AS average_score,

        COUNT(*) AS assessments_completed

    FROM engagement_dw.fact_assessment_submission

    WHERE score IS NOT NULL

    GROUP BY

        student_key,

        course_key
)

SELECT

    ds.id_student,

    ds.gender,

    ds.age_band,

    ds.highest_education,

    ds.disability,

    ds.final_result,

    dc.code_module,

    dc.code_presentation,

    fc.churn_score,

    fc.risk_level,

    fc.engagement_risk_points,

    fc.assessment_risk_points,

    fc.withdrawal_risk_points,

    ISNULL(es.total_clicks,0) AS total_clicks,

    ISNULL(es.total_activities,0) AS total_activities,

    ISNULL(ass.average_score,0) AS average_score,

    ISNULL(ass.assessments_completed,0) AS assessments_completed

FROM engagement_dw.fact_churn_score fc

INNER JOIN engagement_dw.dim_student ds
    ON fc.student_key = ds.student_key

INNER JOIN engagement_dw.dim_course dc
    ON fc.course_key = dc.course_key

LEFT JOIN EngagementSummary es
    ON fc.student_key = es.student_key
   AND fc.course_key = es.course_key

LEFT JOIN AssessmentSummary ass
    ON fc.student_key = ass.student_key
   AND fc.course_key = ass.course_key;
GO

SELECT TOP (20) *
FROM engagement_dw.vw_student_risk;

SELECT TOP (10)
       id_student,
       code_module,
       total_clicks,
       total_activities
FROM engagement_dw.vw_student_risk
ORDER BY total_clicks DESC;



IF OBJECT_ID('engagement_dw.vw_course_summary', 'V') IS NOT NULL
    DROP VIEW engagement_dw.vw_course_summary;
GO

CREATE VIEW engagement_dw.vw_course_summary
AS

WITH EngagementSummary AS
(
    SELECT

        course_key,

        AVG(CAST(sum_click AS FLOAT)) AS average_daily_clicks,

        SUM(sum_click) AS total_clicks,

        SUM(activity_count) AS total_activities

    FROM engagement_dw.fact_engagement_daily

    GROUP BY course_key
),

AssessmentSummary AS
(
    SELECT

        course_key,

        AVG(CAST(score AS FLOAT)) AS average_assessment_score,

        COUNT(*) AS total_assessments

    FROM engagement_dw.fact_assessment_submission

    WHERE score IS NOT NULL

    GROUP BY course_key
)

SELECT

    dc.course_key,

    dc.code_module,

    dc.code_presentation,

    COUNT(DISTINCT fc.student_key) AS total_students,

    AVG(CAST(fc.churn_score AS FLOAT)) AS average_churn_score,

    es.average_daily_clicks,

    es.total_clicks,

    es.total_activities,

    ass.average_assessment_score,

    ass.total_assessments,

    SUM(CASE WHEN fc.risk_level = 'High' THEN 1 ELSE 0 END) AS high_risk_students,

    SUM(CASE WHEN fc.risk_level = 'Medium' THEN 1 ELSE 0 END) AS medium_risk_students,

    SUM(CASE WHEN fc.risk_level = 'Low' THEN 1 ELSE 0 END) AS low_risk_students,

    SUM(CASE WHEN ds.final_result = 'Pass' THEN 1 ELSE 0 END) AS passed_students,

    SUM(CASE WHEN ds.final_result = 'Fail' THEN 1 ELSE 0 END) AS failed_students,

    SUM(CASE WHEN ds.final_result = 'Withdrawn' THEN 1 ELSE 0 END) AS withdrawn_students,

    SUM(CASE WHEN ds.final_result = 'Distinction' THEN 1 ELSE 0 END) AS distinction_students

FROM engagement_dw.fact_churn_score fc

INNER JOIN engagement_dw.dim_course dc
    ON fc.course_key = dc.course_key

INNER JOIN engagement_dw.dim_student ds
    ON fc.student_key = ds.student_key

LEFT JOIN EngagementSummary es
    ON fc.course_key = es.course_key

LEFT JOIN AssessmentSummary ass
    ON fc.course_key = ass.course_key

GROUP BY

    dc.course_key,

    dc.code_module,

    dc.code_presentation,

    es.average_daily_clicks,

    es.total_clicks,

    es.total_activities,

    ass.average_assessment_score,

    ass.total_assessments;
GO

SELECT *
FROM engagement_dw.vw_course_summary;

SELECT COUNT(*)
FROM engagement_dw.vw_course_summary;

USE Student_Churn;
GO

/*=========================================================
    View: Dashboard KPIs
=========================================================*/

IF OBJECT_ID('engagement_dw.vw_dashboard_kpis', 'V') IS NOT NULL
    DROP VIEW engagement_dw.vw_dashboard_kpis;
GO

CREATE VIEW engagement_dw.vw_dashboard_kpis
AS

SELECT

    COUNT(*) AS total_students,

    SUM(CASE
            WHEN risk_level = 'High'
            THEN 1
            ELSE 0
        END) AS high_risk_students,

    SUM(CASE
            WHEN risk_level = 'Medium'
            THEN 1
            ELSE 0
        END) AS medium_risk_students,

    SUM(CASE
            WHEN risk_level = 'Low'
            THEN 1
            ELSE 0
        END) AS low_risk_students,

    AVG(CAST(churn_score AS FLOAT))
        AS average_churn_score,

    AVG(CAST(average_score AS FLOAT))
        AS average_assessment_score,

    AVG(CAST(total_clicks AS FLOAT))
        AS average_total_clicks,

    SUM(CASE
            WHEN final_result = 'Pass'
            THEN 1
            ELSE 0
        END) AS passed_students,

    SUM(CASE
            WHEN final_result = 'Fail'
            THEN 1
            ELSE 0
        END) AS failed_students,

    SUM(CASE
            WHEN final_result = 'Withdrawn'
            THEN 1
            ELSE 0
        END) AS withdrawn_students,

    SUM(CASE
            WHEN final_result = 'Distinction'
            THEN 1
            ELSE 0
        END) AS distinction_students

FROM engagement_dw.vw_student_risk;
GO

SELECT *
FROM engagement_dw.vw_dashboard_kpis;

SELECT COUNT(*) FROM engagement_dw.vw_student_risk;

SELECT COUNT(*) FROM engagement_dw.vw_course_summary;

SELECT COUNT(*) FROM engagement_dw.vw_dashboard_kpis;
SELECT @@SERVERNAME AS ServerName;