use Student_Churn


-- ============================================
-- Create Dimension: Student
-- ============================================

IF OBJECT_ID('engagement_dw.dim_student', 'U') IS NOT NULL
    DROP TABLE engagement_dw.dim_student;
GO

CREATE TABLE engagement_dw.dim_student
(
    student_key INT IDENTITY(1,1) PRIMARY KEY,

    id_student INT NOT NULL,

    gender VARCHAR(10),

    region VARCHAR(100),

    highest_education VARCHAR(100),

    age_band VARCHAR(20),

    disability CHAR(1),

    imd_band VARCHAR(20),

    final_result VARCHAR(20)
);
GO
SELECT *
FROM engagement_dw.dim_student;

-- ============================================
-- Create Dimension: Course
-- ============================================

IF OBJECT_ID('engagement_dw.dim_course', 'U') IS NOT NULL
    DROP TABLE engagement_dw.dim_course;
GO

CREATE TABLE engagement_dw.dim_course
(
    course_key INT IDENTITY(1,1) PRIMARY KEY,

    code_module VARCHAR(10) NOT NULL,

    code_presentation VARCHAR(10) NOT NULL,

    module_presentation_length INT NOT NULL,

    CONSTRAINT UQ_dim_course
        UNIQUE (code_module, code_presentation)
);
GO
SELECT *
FROM engagement_dw.dim_course;

-- ============================================
-- Create Dimension: Date
-- ============================================

-- ============================================
-- Create Dimension: Date
-- ============================================

IF OBJECT_ID('engagement_dw.dim_date', 'U') IS NOT NULL
    DROP TABLE engagement_dw.dim_date;
GO

CREATE TABLE engagement_dw.dim_date
(
    date_key INT PRIMARY KEY,

    course_day INT NOT NULL,

    course_week INT NOT NULL,

    course_phase VARCHAR(30) NOT NULL
);
GO

-- ============================================
-- Create Dimension: Assessment
-- ============================================

IF OBJECT_ID('engagement_dw.dim_assessment', 'U') IS NOT NULL
    DROP TABLE engagement_dw.dim_assessment;
GO

CREATE TABLE engagement_dw.dim_assessment
(
    assessment_key INT IDENTITY(1,1) PRIMARY KEY,

    id_assessment INT NOT NULL UNIQUE,

    assessment_type VARCHAR(30),

    weight FLOAT,

    assessment_date INT
);
GO

-- ============================================
-- Create Dimension: Activity Type
-- ============================================

IF OBJECT_ID('engagement_dw.dim_activity_type', 'U') IS NOT NULL
    DROP TABLE engagement_dw.dim_activity_type;
GO

CREATE TABLE engagement_dw.dim_activity_type
(
    activity_key INT IDENTITY(1,1) PRIMARY KEY,

    id_site INT NOT NULL UNIQUE,

    activity_type VARCHAR(100)
);
GO

SELECT COUNT(*) FROM engagement_dw.dim_student;

SELECT COUNT(*) FROM engagement_dw.dim_course;

SELECT COUNT(*) FROM engagement_dw.dim_assessment;

SELECT COUNT(*) FROM engagement_dw.dim_activity_type;

SELECT TOP 10 *
FROM engagement_dw.dim_student;

SELECT TOP 10 *
FROM engagement_dw.dim_course;

SELECT TOP 10 *
FROM engagement_dw.dim_assessment;

SELECT TOP 10 *
FROM engagement_dw.dim_activity_type;


SELECT TOP 700 *
FROM engagement_dw.dim_date;
