use Student_Churn


-- Create the quarantine schema if it doesn't already exist
IF NOT EXISTS (
    SELECT *
    FROM sys.schemas
    WHERE name = 'engagement_quarantine'
)
BEGIN
    EXEC('CREATE SCHEMA engagement_quarantine');
END
GO
SELECT name
FROM sys.schemas
ORDER BY name;
SELECT
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'engagement_quarantine';
SELECT TOP 0 *
FROM engagement_quarantine.studentInfo;

SELECT COUNT(*)
FROM engagement_quarantine.studentInfo;