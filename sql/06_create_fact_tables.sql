 


-- ==========================================================
-- FACT: Student Daily Engagement
-- Grain:
-- One Student × One Course × One Course Day × One Activity Type
-- ==========================================================

IF OBJECT_ID('engagement_dw.fact_engagement_daily', 'U') IS NOT NULL
    DROP TABLE engagement_dw.fact_engagement_daily;
GO

CREATE TABLE engagement_dw.fact_engagement_daily
(
    student_key INT NOT NULL,

    course_key INT NOT NULL,

    course_date_key INT NOT NULL,

    activity_key INT NOT NULL,

    sum_click INT NOT NULL,

    activity_count INT NOT NULL,

    CONSTRAINT PK_fact_engagement_daily
        PRIMARY KEY
        (
            student_key,
            course_key,
            course_date_key,
            activity_key
        ),

    CONSTRAINT FK_FED_Student
        FOREIGN KEY (student_key)
        REFERENCES engagement_dw.dim_student(student_key),

    CONSTRAINT FK_FED_Course
        FOREIGN KEY (course_key)
        REFERENCES engagement_dw.dim_course(course_key),

    CONSTRAINT FK_FED_Date
        FOREIGN KEY (course_date_key)
        REFERENCES engagement_dw.dim_date(date_key),

    CONSTRAINT FK_FED_Activity
        FOREIGN KEY (activity_key)
        REFERENCES engagement_dw.dim_activity_type(activity_key)
);
GO

SELECT *
FROM engagement_dw.fact_engagement_daily;

-- ==========================================================
-- FACT: Assessment Submission
-- Grain:
-- One Student × One Assessment
-- ==========================================================

IF OBJECT_ID('engagement_dw.fact_assessment_submission', 'U') IS NOT NULL
    DROP TABLE engagement_dw.fact_assessment_submission;
GO

CREATE TABLE engagement_dw.fact_assessment_submission
(
    student_key INT NOT NULL,

    course_key INT NOT NULL,

    assessment_key INT NOT NULL,

    score FLOAT NULL,

    is_banked BIT NOT NULL,

    CONSTRAINT PK_fact_assessment_submission
        PRIMARY KEY
        (
            student_key,
            assessment_key
        ),

    CONSTRAINT FK_FAS_Student
        FOREIGN KEY (student_key)
        REFERENCES engagement_dw.dim_student(student_key),

    CONSTRAINT FK_FAS_Course
        FOREIGN KEY (course_key)
        REFERENCES engagement_dw.dim_course(course_key),

    CONSTRAINT FK_FAS_Assessment
        FOREIGN KEY (assessment_key)
        REFERENCES engagement_dw.dim_assessment(assessment_key)
);
GO

SELECT *
FROM engagement_dw.fact_assessment_submission;

-- ==========================================================
-- FACT: Student Churn Score
-- Grain:
-- One Student × One Course × One Evaluation Day
-- ==========================================================

IF OBJECT_ID('engagement_dw.fact_churn_score', 'U') IS NOT NULL
    DROP TABLE engagement_dw.fact_churn_score;
GO

CREATE TABLE engagement_dw.fact_churn_score
(
    student_key INT NOT NULL,

    course_key INT NOT NULL,

    course_date_key INT NOT NULL,

    engagement_risk_points INT NOT NULL,

    assessment_risk_points INT NOT NULL,

    withdrawal_risk_points INT NOT NULL,

    churn_score INT NOT NULL,

    risk_level VARCHAR(20) NOT NULL,

    evaluation_timestamp DATETIME2 NOT NULL
        DEFAULT SYSDATETIME(),

    CONSTRAINT PK_fact_churn_score
        PRIMARY KEY
        (
            student_key,
            course_key,
            course_date_key
        ),

    CONSTRAINT FK_FCS_Student
        FOREIGN KEY (student_key)
        REFERENCES engagement_dw.dim_student(student_key),

    CONSTRAINT FK_FCS_Course
        FOREIGN KEY (course_key)
        REFERENCES engagement_dw.dim_course(course_key),

    CONSTRAINT FK_FCS_Date
        FOREIGN KEY (course_date_key)
        REFERENCES engagement_dw.dim_date(date_key)
);
GO


SELECT *
FROM engagement_dw.fact_churn_score;
