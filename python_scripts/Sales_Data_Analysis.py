"""
Sales Data Cleaning & Exploratory Analysis
Author: Dr. Mohammed Soliman
Tools: Python | Pandas | Matplotlib | Seaborn

This script performs:
✅ Data Cleaning
✅ Statistical Summary
✅ Product & Category Analysis
✅ Sales Trend Visualization
✅ Exporting Clean Dataset
"""

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path

# Toggle to show or hide plots
show_plots = True

# -------------------------------
# 1️⃣ Load & Inspect Data
# -------------------------------
file_name = "sales_data.csv"
df = pd.read_csv(file_name, sep=';')

print("\nInitial Data Snapshot:")
display(df.head())
print(df.info())

# -------------------------------
# 2️⃣ Data Cleaning
# -------------------------------
df["Date"] = pd.to_datetime(df["Date"], dayfirst=True, errors="coerce")

# Clean text columns (trim + remove extra spaces)
for col in df.select_dtypes(include='object').columns:
    df[col] = df[col].str.replace(r"\s+", " ", regex=True).str.strip()

print("\nMissing Values:")
print(df.isnull().sum())

# -------------------------------
# 3️⃣ Descriptive Statistics
# -------------------------------
print("\nDescriptive Statistics:")
print(df["Total_Sales"].describe())

mean_sales = df["Total_Sales"].mean()
median_sales = df["Total_Sales"].median()
std_sales = df["Total_Sales"].std()

print(f"\nMean Sales: {mean_sales}")
print(f"Median Sales: {median_sales}")
print(f"Std Deviation: {std_sales}")

# -------------------------------
# 4️⃣ Boxplots - Price & Sales
# -------------------------------
if show_plots:
    plt.figure(figsize=(12, 6))
    plt.subplot(1, 2, 1)
    plt.boxplot(df["Price"], patch_artist=True)
    plt.title("Product Price Distribution")

    plt.subplot(1, 2, 2)
    plt.boxplot(df["Total_Sales"], patch_artist=True)
    plt.title("Total Sales Distribution")

    plt.tight_layout()
    plt.show()

# -------------------------------
# 5️⃣ Frequency Analysis
# -------------------------------
print("\nProduct Frequency:")
print(df["Product"].value_counts())

print("\nCategory Frequency:")
print(df["Category"].value_counts())

print("\nProduct % Share:")
print((df["Product"].value_counts(normalize=True) * 100).round(2).astype(str) + "%")

print("\nCategory % Share:")
print((df["Category"].value_counts(normalize=True) * 100).round(2).astype(str) + "%")

# -------------------------------
# 6️⃣ Aggregation
# -------------------------------
print("\nTotal Quantity per Product:")
print(df.groupby("Product")["Quantity"].sum())

print("\nTotal Sales per Product:")
print(df.groupby("Product")["Total_Sales"].sum())

# -------------------------------
# 7️⃣ Phone Sales Trend
# -------------------------------
phone_sales = df[df["Product"] == "Phone"]

if show_plots and not phone_sales.empty:
    plt.figure(figsize=(10, 5))
    plt.bar(phone_sales["Date"], phone_sales["Total_Sales"])
    plt.title("Phone Sales Over Time")
    plt.xlabel("Date")
    plt.ylabel("Total Sales")
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()

# -------------------------------
# 8️⃣ Filter High Sales
# -------------------------------
print("\nHigh Sales (>2000):")
print(df[df["Total_Sales"] > 2000].head())

# -------------------------------
# 9️⃣ Top & Bottom Products
# -------------------------------
sales_by_product = df.groupby("Product")["Total_Sales"].sum()

print("\nTop 3 Products by Sales:")
print(sales_by_product.nlargest(3))

print("\nBottom 3 Products by Sales:")
print(sales_by_product.nsmallest(3))

# -------------------------------
# 🔥 Quartile Analysis - Low vs High Performers
# -------------------------------
Q1 = sales_by_product.quantile(0.25)

low_sales_products = sales_by_product[sales_by_product <= Q1]
high_sales_products = sales_by_product[sales_by_product > Q1]

print("\nLow Sales Products (<= Q1):")
print(low_sales_products)

print("\nHigh Sales Products (> Q1):")
print(high_sales_products)

# -------------------------------
# 1️⃣0️⃣ Heatmap - Product Demand
# -------------------------------
if show_plots:
    plt.figure(figsize=(7, 6))
    sns.heatmap(
        df.pivot_table(index="Product", values="Quantity", aggfunc="sum"),
        annot=True, fmt=".0f", cmap="coolwarm",
        linewidths=1, linecolor="black"
    )
    plt.title("Heatmap - Product Demand (Quantity)")
    plt.show()

# -------------------------------
# ✅ Export Cleaned Data
# -------------------------------
output_path = Path("output/sales_processed_data.csv")
output_path.parent.mkdir(parents=True, exist_ok=True)
df.to_csv(output_path, index=False, encoding="utf-8-sig")

print(f"\n✅ Processed dataset saved successfully at: {output_path}")
print("\n🎯 Script Finished Successfully ✅")
