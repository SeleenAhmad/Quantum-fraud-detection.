# Quantum-CRYPTO
end to end data analysis project for quantum vs classical systems in detecting identity fraud 
#  Quantum vs Classical Cryptography: Fraud Detection & Profit Analysis

This project presents an **end-to-end data analysis** comparing **Classical cryptographic systems** with **Quantum cryptography** in the context of **fraud detection, security strength, and financial performance**.
The dataset is intentionally **messy and realistic**, designed to mirror real-world financial and security data pipelines.

---

##  Project Objectives

* Compare **fraud detection effectiveness** between Classical and Quantum cryptography
* Evaluate **security strength vs financial profitability** trade-offs
* Perform **robust data cleaning** on noisy, imperfect data
* Build an **interactive Power BI dashboard** using proper DAX measures
* Prepare the dataset for **future regression and predictive modeling**

---

##  Key Questions Answered

* Does Quantum cryptography reduce fraud compared to Classical methods?
* How does higher security affect **expected profit**?
* Are there **regional differences** in performance and latency?
* Is higher security always financially optimal?

---

##  Dataset Overview

**Type:** Synthetic but realistic financial-security data
**Rows:** ~7,500 (after cleaning)
**Features:**

| Column                  | Description                                       |
| ----------------------- | ------------------------------------------------- |
| `transaction_id`        | Unique transaction identifier (hidden in visuals) |
| `region`                | Transaction region (with missing values)          |
| `protocol_type`         | Classical or Quantum cryptography                 |
| `transaction_value_usd` | Transaction monetary value                        |
| `fraud_detected`        | Binary fraud indicator (1 = fraud)                |
| `security_level_score`  | Simulated security robustness score               |
| `expected_profit_usd`   | Net profit after fraud losses                     |
| `latency_ms`            | Network / processing latency                      |

###  Intentional Data Issues

* Missing values
* Duplicate transactions
* Outliers
* Skewed distributions

These are **features, not bugs**, included to reflect real production data.

---

##  Data Cleaning Steps

* Removed duplicate transactions based on `transaction_id`
* Imputed missing numeric values using **median** (robust to outliers)
* Filled missing categorical values using **mode**
* Preserved raw data for reproducibility

---

##  Power BI Dashboard

### Features

* Global slicers synced across pages (Region, Protocol)
* Ethical handling of sensitive identifiers (transaction IDs hidden)
* Explicit DAX measures (no implicit aggregation)

### Core DAX Measures

```DAX
Fraud Rate =
DIVIDE(
    SUM ( fraud_data[fraud_detected] ),
    COUNTROWS ( fraud_data )
)
```

```DAX
Average Profit =
AVERAGE ( fraud_data[expected_profit_usd] )
```

```DAX
Total Transaction Value =
SUM ( fraud_data[transaction_value_usd] )
```

---

##  Key Findings (High-Level)

* Quantum cryptography shows **significantly higher security scores**
* Fraud incidence is **lower under Quantum protocols**
* Profitability depends on **transaction value, region, and latency**, not security alone
* Classical systems still dominate volume but at higher fraud exposure

---

## Academic & Professional Relevance

This project is suitable for:

* Data Analytics portfolios
* Bachelor-level thesis or capstone projects
* Business intelligence case studies
* Security & cryptography impact analysis

It demonstrates:

* Ethical data handling
* Strong analytical reasoning
* Correct use of DAX and Power BI
* Readiness for regression and predictive modeling

---

##  Future Work

* Time-series extension (adoption trends)
* Regression models for profit and fraud prediction
* Causal inference on Quantum adoption
* Cost–benefit simulation scenarios

---

##  Tools Used

* Python (pandas, numpy)
* Power BI
* DAX
* Jupyter Notebook

---

##  Notes

This dataset is **synthetic** and created solely for educational and analytical purposes.

---

⭐ If you found this project interesting, feel free to star the repository or suggest improvements.
