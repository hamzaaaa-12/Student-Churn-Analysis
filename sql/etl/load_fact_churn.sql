use Student_Churn




;WITH

EngagementMetrics AS
(
    SELECT
        student_key,
        course_key,
        AVG(CAST(sum_click AS FLOAT)) AS avg_daily_clicks,
        MAX(course_date_key) AS latest_course_date_key
    FROM engagement_dw.fact_engagement_daily
    GROUP BY
        student_key,
        course_key
),

EngagementQuartiles AS
(
    SELECT DISTINCT
        PERCENTILE_CONT(0.25)
            WITHIN GROUP (ORDER BY avg_daily_clicks)
            OVER() AS Q1,

        PERCENTILE_CONT(0.75)
            WITHIN GROUP (ORDER BY avg_daily_clicks)
            OVER() AS Q3
    FROM EngagementMetrics
),

RiskRule AS
(
    SELECT
        low_points,
        medium_points,
        high_points
    FROM engagement_dw.dim_risk_rule
    WHERE rule_name='Engagement Risk'
),

EngagementRisk AS
(
    SELECT

        em.student_key,

        em.course_key,

        em.latest_course_date_key,

        em.avg_daily_clicks,

        CASE
            WHEN em.avg_daily_clicks <= eq.Q1 THEN rr.low_points
            WHEN em.avg_daily_clicks <= eq.Q3 THEN rr.medium_points
            ELSE rr.high_points
        END AS engagement_risk_points

    FROM EngagementMetrics em

    CROSS JOIN EngagementQuartiles eq

    CROSS JOIN RiskRule rr
),

AssessmentMetrics AS
(
    SELECT

        student_key,

        course_key,

        AVG(CAST(score AS FLOAT)) AS avg_score

    FROM engagement_dw.fact_assessment_submission

    WHERE score IS NOT NULL

    GROUP BY

        student_key,

        course_key
)

,

AssessmentQuartiles AS
(
    SELECT DISTINCT

        PERCENTILE_CONT(0.25)
        WITHIN GROUP (ORDER BY avg_score)
        OVER() AS Q1,

        PERCENTILE_CONT(0.75)
        WITHIN GROUP (ORDER BY avg_score)
        OVER() AS Q3

    FROM AssessmentMetrics
)
,

AssessmentRiskRule AS
(
    SELECT

        low_points,

        medium_points,

        high_points

    FROM engagement_dw.dim_risk_rule

    WHERE rule_name = 'Assessment Risk'
),

AssessmentRisk AS
(
    SELECT

        am.student_key,

        am.course_key,

        am.avg_score,

        CASE

            WHEN am.avg_score <= aq.Q1
                THEN rr.low_points

            WHEN am.avg_score <= aq.Q3
                THEN rr.medium_points

            ELSE rr.high_points

        END AS assessment_risk_points

    FROM AssessmentMetrics am

    CROSS JOIN AssessmentQuartiles aq

    CROSS JOIN AssessmentRiskRule rr
)

,

WithdrawalRiskRule AS
(
    SELECT

        low_points

    FROM engagement_dw.dim_risk_rule

    WHERE rule_name = 'Withdrawal Risk'
),

WithdrawalRisk AS
(
    SELECT

        em.student_key,

        em.course_key,

        CASE

            WHEN ds.final_result = 'Withdrawn'
                THEN rr.low_points

            ELSE 0

        END AS withdrawal_risk_points

    FROM EngagementMetrics em

    INNER JOIN engagement_dw.dim_student ds
        ON em.student_key = ds.student_key

    CROSS JOIN WithdrawalRiskRule rr
),


FinalRisk AS
(
    SELECT

        er.student_key,

        er.course_key,

        er.latest_course_date_key AS course_date_key,

        er.engagement_risk_points,

        ISNULL(ar.assessment_risk_points, 0) AS assessment_risk_points,

        ISNULL(wr.withdrawal_risk_points, 0) AS withdrawal_risk_points,

        er.engagement_risk_points
        + ISNULL(ar.assessment_risk_points, 0)
        + ISNULL(wr.withdrawal_risk_points, 0)
        AS churn_score

    FROM EngagementRisk er

    LEFT JOIN AssessmentRisk ar

        ON er.student_key = ar.student_key

       AND er.course_key = ar.course_key

    LEFT JOIN WithdrawalRisk wr

        ON er.student_key = wr.student_key

       AND er.course_key = wr.course_key
),
RiskLevel AS
(
    SELECT

        student_key,

        course_key,

        course_date_key,

        engagement_risk_points,

        assessment_risk_points,

        withdrawal_risk_points,

        churn_score,

        CASE

            WHEN churn_score >= 70
                THEN 'High'

            WHEN churn_score >= 40
                THEN 'Medium'

            ELSE 'Low'

        END AS risk_level

    FROM FinalRisk
)




INSERT INTO engagement_dw.fact_churn_score
(
    student_key,
    course_key,
    course_date_key,
    engagement_risk_points,
    assessment_risk_points,
    withdrawal_risk_points,
    churn_score,
    risk_level
)

SELECT
    student_key,
    course_key,
    course_date_key,
    engagement_risk_points,
    assessment_risk_points,
    withdrawal_risk_points,
    churn_score,
    risk_level
FROM RiskLevel;



SELECT COUNT(*)
FROM engagement_dw.fact_engagement_daily;

SELECT COUNT(*)
FROM engagement_dw.fact_assessment_submission;

SELECT COUNT(*)
FROM engagement_dw.fact_churn_score;