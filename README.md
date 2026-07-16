# Student Churn Analytics Data Warehouse

## Overview

This project implements a complete **Data Engineering solution** for analyzing student engagement and churn risk using the **Open University Learning Analytics Dataset (OULAD)**.

The project demonstrates the end-to-end Data Engineering lifecycle:

- Data Cleaning
- ETL Pipeline
- Data Warehouse Design
- Star Schema Modeling
- Fact & Dimension Tables
- SQL Views
- Business KPIs
- Power BI Dashboard

The final dashboard enables academic staff to monitor student engagement, identify high-risk students, and evaluate course performance.

---

# Project Architecture

```
                Raw CSV Files
                      │
                      ▼
              Python Data Cleaning
                      │
                      ▼
              SQL Server Staging
                      │
                      ▼
              ETL Transformations
                      │
                      ▼
          Student_Churn Data Warehouse
                      │
          ┌───────────┴───────────┐
          │                       │
          ▼                       ▼
     Dimension Tables         Fact Tables
          │                       │
          └───────────┬───────────┘
                      ▼
                  SQL Views
                      ▼
                 Power BI Dashboard
```

---

# Technologies Used

- SQL Server
- T-SQL
- Python
- Pandas
- Power BI
- Star Schema
- Data Warehouse
- Git
- GitHub

---

# Dataset

Dataset Used:

**Open University Learning Analytics Dataset (OULAD)**

Files include:

- assessments
- courses
- studentAssessment
- studentInfo
- studentRegistration
- studentVle
- vle

---

# Project Structure

```
Student_Churn_Project/

│
├── data/
│   ├── raw/
│   ├── cleaned/
│
├── sql/
│   ├── schemas/
│   ├── dimensions/
│   ├── facts/
│   ├── views/
│   └── procedures/
│
├── python/
│   ├── cleaning/
│   └── etl/
│
├── powerbi/
│   └── Student_Churn.pbix
│
├── screenshots/
│
└── README.md
```

---

# Data Warehouse Design

## Star Schema

### Dimension Tables

- dim_student
- dim_course
- dim_assessment
- dim_date
- dim_risk_rule

---

### Fact Tables

- fact_engagement_daily
- fact_assessment_submission
- fact_student_churn

---

# ETL Pipeline

The ETL process consists of:

1. Extract CSV files.
2. Clean missing and invalid values using Python.
3. Load cleaned data into SQL Server staging tables.
4. Transform data into a dimensional model.
5. Populate dimension tables.
6. Populate fact tables.
7. Build analytical SQL views.
8. Connect Power BI.

---

# Business Rules

The project calculates a **Student Churn Score** using three components:

## Engagement Risk

Calculated from:

- Average Daily Clicks

Risk is determined using quartiles.

---

## Assessment Risk

Calculated from:

- Average Assessment Score

Risk is also determined using quartiles.

---

## Withdrawal Risk

Students with a final result of **Withdrawn** receive additional risk points.

---

## Final Churn Score

```
Churn Score =
Engagement Risk
+
Assessment Risk
+
Withdrawal Risk
```

The score is classified into:

- Low Risk
- Medium Risk
- High Risk

---

# SQL Views

The warehouse exposes analytical views for reporting:

### Student Risk

Contains:

- Student Information
- Course Information
- Assessment Metrics
- Engagement Metrics
- Churn Score
- Risk Level

---

### Course Summary

Contains:

- Average Churn Score
- Average Assessment Score
- Student Counts
- Passed Students
- Failed Students
- Distinction Students

---

### Dashboard KPIs

Provides dashboard-level metrics including:

- Total Students
- High Risk Students
- Average Churn Score
- Average Assessment Score
- Total Clicks

---

# Power BI Dashboard

The dashboard provides executive insights into student engagement and churn.

## KPI Cards

- Total Students
- High Risk Students
- Average Assessment Score
- Average Churn Score

---

## Visualizations

### Risk Distribution

Displays:

- Low Risk
- Medium Risk
- High Risk

---

### Students by Final Result

Displays:

- Pass
- Distinction
- Fail
- Withdrawn

---

### Course Churn Risk

Ranks courses by:

- Average Churn Score

---

### Course Performance

Ranks courses by:

- Average Assessment Score

---

### High Risk Students

Detailed student-level table including:

- Student ID
- Course
- Presentation
- Risk Level
- Churn Score
- Assessment Score
- Final Result

---

# Dashboard Features

- Interactive filtering
- Risk analysis
- Course comparison
- Student-level drill-down
- Executive KPI monitoring

---

# Key Business Insights

The dashboard helps answer questions such as:

- Which students are most likely to churn?
- Which courses have the highest churn risk?
- Which courses have the best academic performance?
- How are students distributed across risk levels?
- How do assessment scores relate to churn risk?

---

# Future Improvements

Potential future enhancements include:

- Machine Learning churn prediction
- Real-time data streaming using Kafka
- Azure Data Factory integration
- Microsoft Fabric implementation
- Incremental ETL
- Automated scheduling with Apache Airflow
- Streamlit web application
- Email alerts for high-risk students

---

# Repository

```
git clone https://github.com/hamzaaaa-12/Student-Churn-Analytics.git
```

---

# Author

**Hamza Ibrahim**

Computer Science Student

Microsoft Data Engineer Trainee

Faculty of Computer Science and Artificial Intelligence

Helwan University

---

# License

This project is intended for educational purposes.