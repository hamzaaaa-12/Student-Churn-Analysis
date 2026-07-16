USE Student_Churn;
GO

/*==========================================================
  Dimension Validation Report
==========================================================*/

PRINT '==========================================';
PRINT 'DIMENSION VALIDATION REPORT';
PRINT '==========================================';


/*==========================================================
  Row Counts
==========================================================*/

PRINT '';
PRINT '1. Row Counts';

SELECT 'dim_student' AS table_name, COUNT(*) AS row_count
FROM engagement_dw.dim_student

UNION ALL

SELECT 'dim_course', COUNT(*)
FROM engagement_dw.dim_course

UNION ALL

SELECT 'dim_assessment', COUNT(*)
FROM engagement_dw.dim_assessment

UNION ALL

SELECT 'dim_activity_type', COUNT(*)
FROM engagement_dw.dim_activity_type

UNION ALL

SELECT 'dim_date', COUNT(*)
FROM engagement_dw.dim_date;



/*==========================================================
  Duplicate Natural Keys
==========================================================*/

PRINT '';
PRINT '2. Duplicate Business Keys';


-- Student

SELECT
'id_student' AS business_key,
COUNT(*) AS duplicate_count
FROM
(
SELECT id_student
FROM engagement_dw.dim_student
GROUP BY id_student
HAVING COUNT(*) > 1
)d;


-- Course

SELECT
'course' AS business_key,
COUNT(*) AS duplicate_count
FROM
(
SELECT code_module, code_presentation
FROM engagement_dw.dim_course
GROUP BY code_module, code_presentation
HAVING COUNT(*) > 1
)d;


-- Assessment

SELECT
'id_assessment' AS business_key,
COUNT(*) AS duplicate_count
FROM
(
SELECT id_assessment
FROM engagement_dw.dim_assessment
GROUP BY id_assessment
HAVING COUNT(*) > 1
)d;


-- Activity

SELECT
'id_site' AS business_key,
COUNT(*) AS duplicate_count
FROM
(
SELECT id_site
FROM engagement_dw.dim_activity_type
GROUP BY id_site
HAVING COUNT(*) > 1
)d;



/*==========================================================
  NULL Business Keys
==========================================================*/

PRINT '';
PRINT '3. NULL Business Keys';

SELECT
'dim_student' AS table_name,
COUNT(*) AS null_keys
FROM engagement_dw.dim_student
WHERE id_student IS NULL

UNION ALL

SELECT
'dim_course',
COUNT(*)
FROM engagement_dw.dim_course
WHERE code_module IS NULL
   OR code_presentation IS NULL

UNION ALL

SELECT
'dim_assessment',
COUNT(*)
FROM engagement_dw.dim_assessment
WHERE id_assessment IS NULL

UNION ALL

SELECT
'dim_activity_type',
COUNT(*)
FROM engagement_dw.dim_activity_type
WHERE id_site IS NULL

UNION ALL

SELECT
'dim_date',
COUNT(*)
FROM engagement_dw.dim_date
WHERE course_day IS NULL;



/*==========================================================
  Surrogate Key Validation
==========================================================*/

PRINT '';
PRINT '4. Surrogate Keys';

SELECT
'dim_student' AS table_name,
MIN(student_key) AS min_key,
MAX(student_key) AS max_key
FROM engagement_dw.dim_student

UNION ALL

SELECT
'dim_course',
MIN(course_key),
MAX(course_key)
FROM engagement_dw.dim_course

UNION ALL

SELECT
'dim_assessment',
MIN(assessment_key),
MAX(assessment_key)
FROM engagement_dw.dim_assessment

UNION ALL

SELECT
'dim_activity_type',
MIN(activity_key),
MAX(activity_key)
FROM engagement_dw.dim_activity_type

UNION ALL

SELECT
'dim_date',
MIN(date_key),
MAX(date_key)
FROM engagement_dw.dim_date;



/*==========================================================
  Sample Records
==========================================================*/

PRINT '';
PRINT '5. Sample Data';

SELECT TOP (5) *
FROM engagement_dw.dim_student;

SELECT TOP (5) *
FROM engagement_dw.dim_course;

SELECT TOP (5) *
FROM engagement_dw.dim_assessment;

SELECT TOP (5) *
FROM engagement_dw.dim_activity_type;

SELECT TOP (5) *
FROM engagement_dw.dim_date;



PRINT '';
PRINT '==========================================';
PRINT 'DIMENSION VALIDATION COMPLETED';
PRINT '==========================================';
GO