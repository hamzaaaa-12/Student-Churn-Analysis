use Student_Churn
/*=========================================================
  Bronze Layer
  Raw OULAD Tables
=========================================================*/

----------------------------------------------------------
-- studentInfo
----------------------------------------------------------
CREATE TABLE engagement_raw.studentInfo
(
    code_module                 VARCHAR(10),
    code_presentation           VARCHAR(10),
    id_student                  INT,
    gender                      VARCHAR(10),
    region                      VARCHAR(100),
    highest_education           VARCHAR(100),
    imd_band                    VARCHAR(50),
    age_band                    VARCHAR(50),
    num_of_prev_attempts        INT,
    studied_credits             INT,
    disability                  VARCHAR(10),
    final_result                VARCHAR(50)
);

----------------------------------------------------------
-- studentRegistration
----------------------------------------------------------
CREATE TABLE engagement_raw.studentRegistration
(
    code_module           VARCHAR(10),
    code_presentation     VARCHAR(10),
    id_student            INT,
    date_registration     INT,
    date_unregistration   INT
);

----------------------------------------------------------
-- studentVle
----------------------------------------------------------
CREATE TABLE engagement_raw.studentVle
(
    code_module          VARCHAR(10),
    code_presentation    VARCHAR(10),
    id_student           INT,
    id_site              INT,
    date                 INT,
    sum_click            INT
);

----------------------------------------------------------
-- studentAssessment
----------------------------------------------------------
CREATE TABLE engagement_raw.studentAssessment
(
    id_assessment      INT,
    id_student         INT,
    date_submitted     INT,
    is_banked          INT,
    score              FLOAT
);

----------------------------------------------------------
-- assessments
----------------------------------------------------------
CREATE TABLE engagement_raw.assessments
(
    code_module          VARCHAR(10),
    code_presentation    VARCHAR(10),
    id_assessment        INT,
    assessment_type      VARCHAR(20),
    date                 INT,
    weight               FLOAT
);

----------------------------------------------------------
-- vle
----------------------------------------------------------
CREATE TABLE engagement_raw.vle
(
    id_site          INT,
    code_module      VARCHAR(10),
    code_presentation VARCHAR(10),
    activity_type    VARCHAR(100),
    week_from        INT,
    week_to          INT
);

----------------------------------------------------------
-- courses
----------------------------------------------------------
CREATE TABLE engagement_raw.courses
(
    code_module          VARCHAR(10),
    code_presentation    VARCHAR(10),
    module_presentation_length INT
);
SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'engagement_raw';

SELECT COUNT(*) FROM engagement_raw.studentInfo;

SELECT COUNT(*) FROM engagement_raw.studentRegistration;

SELECT COUNT(*) FROM engagement_raw.studentVle;

SELECT COUNT(*) FROM engagement_raw.studentAssessment;

SELECT COUNT(*) FROM engagement_raw.assessments;

SELECT COUNT(*) FROM engagement_raw.vle;

SELECT COUNT(*) FROM engagement_raw.courses;

SELECT *
FROM engagement_raw.studentInfo
WHERE id_student = 240641;