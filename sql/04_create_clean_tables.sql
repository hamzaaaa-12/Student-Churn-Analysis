use Student_Churn

------------------------------------------------------------
-- Remove old tables if they exist
------------------------------------------------------------

DROP TABLE IF EXISTS engagement_clean.studentInfo;
DROP TABLE IF EXISTS engagement_clean.studentRegistration;
DROP TABLE IF EXISTS engagement_clean.studentVle;
DROP TABLE IF EXISTS engagement_clean.studentAssessment;
DROP TABLE IF EXISTS engagement_clean.assessments;
DROP TABLE IF EXISTS engagement_clean.vle;
DROP TABLE IF EXISTS engagement_clean.courses;
GO

------------------------------------------------------------
-- Create empty Silver tables
------------------------------------------------------------

SELECT TOP 0 *
INTO engagement_clean.studentInfo
FROM engagement_raw.studentInfo;

SELECT TOP 0 *
INTO engagement_clean.studentRegistration
FROM engagement_raw.studentRegistration;

SELECT TOP 0 *
INTO engagement_clean.studentVle
FROM engagement_raw.studentVle;

SELECT TOP 0 *
INTO engagement_clean.studentAssessment
FROM engagement_raw.studentAssessment;

SELECT TOP 0 *
INTO engagement_clean.assessments
FROM engagement_raw.assessments;

SELECT TOP 0 *
INTO engagement_clean.vle
FROM engagement_raw.vle;

SELECT TOP 0 *
INTO engagement_clean.courses
FROM engagement_raw.courses;
GO
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'engagement_clean';

SELECT COUNT(*)
FROM engagement_clean.studentInfo;
SELECT COUNT(*) FROM engagement_clean.studentVle;
SELECT TOP 100 *
FROM engagement_clean.studentInfo;