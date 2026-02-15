# E-Commerce Data Analysis

## 📌 Project Overview
This repository contains an e-commerce data analysis performed using **SQL and Python** on a dataset sourced from Kaggle. The goal of this project is to analyze customer behaviour, product performance, seller performance, delivery trends, and **major churn reasons** (90% churn detected) in the e-commerce data. :contentReference[oaicite:1]{index=1}

## 📊 Key Components
📌 **SQL Queries**  
– Contains analytical SQL queries to extract business insights from the raw e-commerce dataset.

📌 **Python Script**  
– `churn_analysis.py` — Analyzes customer churn patterns and visualizes churn factors.

📌 **Visuals & Insights**
– Delivery analysis graphs  
– Reviews analysis  
– Product & seller quality trends  
– Customer segmentation text files  
– Summary insights collection — revenue, customer types, repeated customers, etc.

## 📂 Repository Structure

├── churn_analysis.py
├── e-commerce_queries.sql
├── REVIEWS ANALYSIS.png
├── delivery analysis.png
├── summary insights.txt
├── customer_type,percentage.txt
├── product_cat_wise_revenue.txt
├── customers and total revenue.txt
├── repeated customers.txt
├── one time customers.txt
├── bad_sellers.txt
├── good_sellers_gold.txt
├── low_review_product
├── good_review_but_less_revenue.txt
├── top_sellers_reveue
└── ...other insight files


## 🔍 What Was Analyzed
✔ Customer churn patterns  
✔ Review vs revenue correlation  
✔ High revenue vs low rating products  
✔ Delivery performance trends  
✔ Seller segmentation by review score  
✔ Repeat vs one-time customers  
✔ Customer value contribution to total revenue  
✔ Product category revenue analysis 

## 📈 Tools & Technologies
- Python (Pandas, Matplotlib / Seaborn)  
- SQL (PostgreSQL / MySQL queries)  
- Git & GitHub  
- Kaggle dataset (E-commerce transaction data) 

## 📌 Insights Summary
This analysis majorly focuses on identifying **why ~90% of customers churn** (stop buying again) and what product/seller/review patterns correlate with revenue performance. 

## 📥 How To Use
1. Clone the repo  
2. Load dataset into your SQL database  
3. Run SQL queries to generate base analytics  
4. Execute `churn_analysis.py` to view Python EDA & visualizations  
5. Review output text files and PNG graphs

## 🛠 Future Work
- Build predictive churn model  
- Integrate RFM/customer segmentation visuals  
- Add Dashboard (Streamlit / Power BI)

