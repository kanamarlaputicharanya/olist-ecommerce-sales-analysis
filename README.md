# olist-ecommerce-sales-analysis
End-to-end e-commerce sales and customer analytics project using Python, SQL, and Power BI.
# Olist E-Commerce Sales & Customer Analytics

## 📌 Project Overview

An end-to-end **E-Commerce Sales and Customer Analytics** project built using **Python, SQL, and Power BI**.

The project analyzes the Brazilian E-Commerce Public Dataset by Olist to understand sales performance, customer behavior, product performance, payment patterns, delivery operations, customer satisfaction, and customer retention.

The analysis combines **Python-based data cleaning and EDA, SQL business analysis, Power BI dashboards, and RFM customer segmentation** to generate actionable business insights and recommendations.

---

## 🎯 Business Problem

An e-commerce business generates large volumes of transactional data, but raw data alone does not provide clear answers to important business questions.

This project aims to answer questions such as:

* How is overall revenue and order performance?
* Which product categories generate the most revenue?
* Which states and cities contribute the most sales?
* How efficient is the delivery process?
* What payment methods do customers prefer?
* How satisfied are customers?
* How many customers are repeat customers?
* Which customers are Champions, Loyal, At Risk, or Lost?
* Which high-value customers are at risk?
* What actions can improve customer retention and business performance?

---

## 📊 Dataset

**Dataset:** Brazilian E-Commerce Public Dataset by Olist

The dataset contains approximately 100K orders and multiple related tables covering:

* Customers
* Orders
* Order Items
* Products
* Sellers
* Payments
* Reviews
* Geolocation
* Product Category Translation

---

## 🛠️ Tools & Technologies

| Tool         | Purpose                                                |
| ------------ | ------------------------------------------------------ |
| Python       | Data cleaning, profiling and exploratory data analysis |
| Pandas       | Data manipulation and cleaning                         |
| NumPy        | Numerical analysis                                     |
| Matplotlib   | Data visualization                                     |
| MySQL        | Business-oriented SQL analysis                         |
| Power BI     | Interactive dashboards and KPI analysis                |
| DAX          | KPI measures and advanced customer analytics           |
| RFM Analysis | Customer segmentation and retention analysis           |
| Excel        | Initial data inspection and documentation              |

---

## 🔄 Project Workflow

```text
Raw Olist Dataset
        ↓
Data Profiling
        ↓
Data Cleaning & Preparation
        ↓
Exploratory Data Analysis
        ↓
SQL Business Analysis
        ↓
Power BI Data Modeling
        ↓
DAX KPI Development
        ↓
RFM Customer Segmentation
        ↓
6 Interactive Dashboards
        ↓
Business Insights
        ↓
Business Recommendations
```

---

# 🐍 Python — Data Cleaning & EDA

Python was used for:

* Dataset profiling
* Missing-value analysis
* Data-type inspection
* Duplicate detection
* Data cleaning
* Outlier investigation
* Revenue analysis
* Product/category analysis
* Customer analysis
* Delivery analysis
* Exploratory visualizations

### Key datasets analyzed

* Customers
* Orders
* Order Items
* Products
* Payments
* Reviews
* Sellers
* Geolocation

---

# 🗄️ SQL Business Analysis

MySQL was used to answer business questions using:

* SELECT
* WHERE
* GROUP BY
* HAVING
* ORDER BY
* JOINs
* Aggregate functions
* CASE statements
* Subqueries
* Window functions
* Date-based analysis

### Example business questions

* What are the top revenue-generating categories?
* Which states generate the highest revenue?
* What is the average order value?
* How many customers are repeat customers?
* Which payment methods are most popular?
* Which states have longer delivery times?
* Which categories receive higher review scores?

---

# 📈 Power BI Dashboards

The project contains **six Power BI dashboards**, each designed around a specific business perspective.

---

## Dashboard 1 — Executive Sales Overview

Provides a high-level view of overall business performance.

### Key KPIs

* Gross Revenue
* Net Revenue
* Average Order Value
* Total Orders
* Freight Cost %
* On-Time Delivery Rate
* Unique Customers

### Key Analysis

* Order status distribution
* Revenue by customer location
* Freight cost by state
* Top product categories by revenue
* Monthly revenue trends

![Dashboard 1](screenshots/dashboard_1.png)

---

## Dashboard 2 — Product & Category Performance

Analyzes product and category-level sales performance.

### Key KPIs

* Products Sold
* Product Categories
* Category Revenue
* Average Order Value
* Top Category Performance

### Key Analysis

* Top categories by revenue
* Lowest revenue categories
* Categories by order volume
* Categories by average order value

![Dashboard 2](screenshots/dashboard_2.png)

---

## Dashboard 3 — Customer & Geographic Analysis

Analyzes customer distribution and geographic sales performance.

### Key KPIs

* Total Customers
* Revenue per Customer
* Orders per Customer
* Average Order Value
* Active States

### Key Analysis

* Revenue by customer city
* Orders by state
* Revenue per customer by state
* Revenue by state
* Average order value by state

![Dashboard 3](screenshots/dashboard_3.png)

---

## Dashboard 4 — Order & Delivery Operations

Analyzes order processing and delivery performance.

### Key Analysis

* Order status
* Delivery performance
* Delivery days
* Order approval time
* State-level delivery performance
* Operational trends

![Dashboard 4](screenshots/dashboard_4.png)

---

## Dashboard 5 — Payments & Customer Satisfaction

Analyzes payment behavior and customer satisfaction.

### Key KPIs

* Total Payment Value
* Average Payment Value
* Payment Transactions
* Average Review Score
* Positive Review Rate

### Key Analysis

* Payment method distribution
* Payment value by method
* Review score distribution
* Review performance by product category
* Customer satisfaction analysis

![Dashboard 5](screenshots/dashboard_5.png)

---

## Dashboard 6 — Advanced Customer Intelligence

The final dashboard focuses on **customer retention, RFM segmentation, and customer value**.

### Key KPIs

| KPI                               |  Value |
| --------------------------------- | -----: |
| Total Customers                   |    96K |
| Repeat Customers                  |     3K |
| Repeat Customer Rate              |  3.12% |
| Estimated Customer Lifetime Value | 574.06 |
| At-Risk Customers                 |   ~30K |
| Estimated Inactivity Rate         |  31.1% |

### Advanced Analysis

* RFM customer segmentation
* Repeat vs one-time customers
* Customer value vs purchase frequency
* Revenue contribution by customer segment
* Top at-risk customers by revenue
* Customer segment filtering

### RFM Segments

* Champions
* Loyal Customers
* Potential Loyalists
* At Risk
* Lost Customers

![Dashboard 6](screenshots/dashboard_6.png)

---

# 👥 RFM Customer Segmentation

RFM analysis was used to understand customer behavior using three dimensions:

### Recency

How recently did the customer purchase?

### Frequency

How many orders did the customer make?

### Monetary

How much revenue did the customer generate?

These metrics were converted into scores and combined to create customer segments.

```text
Recency
   +
Frequency
   +
Monetary
   ↓
RFM Score
   ↓
Customer Segment
```

---

# 💡 Key Business Insights

### 1. Low Customer Retention

The repeat customer rate is approximately **3.12%**, with around **1.03 orders per customer**.

This indicates that the business is highly dependent on one-time purchases.

### 2. Large Lost Customer Segment

Approximately **64.28% of customers are classified as Lost Customers** under the project's RFM segmentation rules.

This represents a significant customer reactivation opportunity.

### 3. Large At-Risk Customer Base

Approximately **30K customers** are classified as At Risk.

These customers represent an important retention opportunity before they move into the Lost segment.

### 4. Revenue Retention Opportunity

At-Risk and Lost customer segments contribute a meaningful share of customer revenue.

Therefore, customer retention is not only a customer-count problem but also a potential revenue-protection opportunity.

### 5. Estimated Customer Lifetime Value

The simplified estimated CLV is approximately **574.06**.

This metric can be used to prioritize customers and retention efforts, although it should not be interpreted as a precise predictive financial CLV.

### 6. Strong Overall Delivery Performance

The overall on-time delivery rate is approximately **97%**.

However, state-level differences can still be investigated to identify regional operational bottlenecks.

### 7. Freight Cost Optimization Opportunity

Freight costs represent approximately **17%** of the measured revenue base.

This creates an opportunity to investigate shipping costs by state, seller, category, and logistics performance.

### 8. Revenue Concentration Across Categories

Several product categories contribute significantly more revenue than others.

This creates opportunities to protect high-performing categories while reviewing weaker categories.

### 9. Geographic Revenue Concentration

Revenue and order activity vary significantly across states, with **São Paulo** being a major market.

This supports the use of regional inventory, marketing, and logistics strategies.

### 10. Credit Card Dominates Payments

Credit card payments represent the dominant payment behavior in the analyzed transactions.

This highlights the importance of maintaining a reliable card-based checkout experience.

---

# 🚀 Business Recommendations

### 1. Improve Customer Retention

Introduce:

* Loyalty programs
* Second-purchase incentives
* Personalized recommendations
* Post-purchase campaigns
* Cross-selling strategies

### 2. Launch RFM-Based Win-Back Campaigns

Target Lost Customers using their previous:

* Product categories
* Purchase value
* Purchase frequency
* Recency

### 3. Prioritize High-Value At-Risk Customers

Customers with high monetary value and declining engagement should receive higher-priority retention campaigns.

### 4. Optimize Logistics Costs

Analyze freight costs by:

* State
* Seller
* Product category
* Product characteristics
* Delivery performance

### 5. Strengthen High-Performing Categories

Maintain inventory availability and marketing investment in categories generating strong revenue.

### 6. Improve Underperforming Categories

Investigate weaker categories based on:

* Demand
* Pricing
* Product quality
* Inventory
* Customer satisfaction

### 7. Develop Regional Strategies

Allocate marketing, inventory, seller coverage, and logistics resources based on state-level demand and performance.

### 8. Optimize Payment Experience

Continue prioritizing reliable credit-card checkout while maintaining alternative payment options.

---

# 📌 Project Outcome

This project transformed raw e-commerce transaction data into an interactive analytics solution using **Python, MySQL, DAX, and Power BI**.

The final solution provides visibility into:

* Sales performance
* Product performance
* Customer behavior
* Geographic performance
* Order operations
* Delivery efficiency
* Payment behavior
* Customer satisfaction
* Customer retention
* RFM segmentation
* Customer value

The analysis identified **customer retention and reactivation as major business opportunities**, supported by the low repeat customer rate and large Lost and At-Risk customer segments.

---

> The Power BI `.pbix` file was not included in the repository because of GitHub upload limitations. The six dashboard screenshots demonstrate the completed Power BI solution.

---

# 👩‍💻 Author

**Charanya Kanamarlaputi**

B.Tech — Computer Science & Engineering (Cyber Security)

### Skills Demonstrated

`Python` `Pandas` `NumPy` `SQL` `MySQL` `Power BI` `DAX` `Excel` `EDA` `RFM Analysis` `Business Analytics`
