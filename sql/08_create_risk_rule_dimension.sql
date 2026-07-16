use Student_Churn



USE Student_Churn;
GO

-- ==========================================================
-- Dimension: Risk Rule
-- Stores configurable business scoring rules
-- ==========================================================

IF OBJECT_ID('engagement_dw.dim_risk_rule', 'U') IS NOT NULL
    DROP TABLE engagement_dw.dim_risk_rule;
GO

CREATE TABLE engagement_dw.dim_risk_rule
(
    rule_key INT IDENTITY(1,1) PRIMARY KEY,

    rule_name VARCHAR(100) NOT NULL UNIQUE,

    metric_name VARCHAR(100) NOT NULL,

    low_points INT NOT NULL,

    medium_points INT NOT NULL,

    high_points INT NOT NULL,

    is_active BIT NOT NULL
        DEFAULT(1)
);
GO
INSERT INTO engagement_dw.dim_risk_rule
(
    rule_name,
    metric_name,
    low_points,
    medium_points,
    high_points
)
VALUES
(
    'Engagement Risk',
    'Average Daily Clicks',
    40,
    20,
    0
),
(
    'Assessment Risk',
    'Average Assessment Score',
    30,
    15,
    0
),
(
    'Withdrawal Risk',
    'Final Result',
    30,
    0,
    0
);
GO

SELECT *
FROM engagement_dw.dim_risk_rule;