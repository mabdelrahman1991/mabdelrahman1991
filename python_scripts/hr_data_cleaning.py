# Script to clean and prepare HR data before Power BI dashboard development
# Author: Dr. Mohammed Soliman

import pandas as pd

# Load data
file_name = "HR.csv"
df = pd.read_csv(file_name, sep=';', encoding='utf-8')

# Preview
print("Initial dataset preview:")
display(df.head())
print(df.info())

# Convert date columns
df["Hire date"] = pd.to_datetime(df["Hire date"], errors='coerce')
df["DOB"] = pd.to_datetime(df["DOB"], errors='coerce')

# Clean text columns
for col in df.select_dtypes(include='object').columns:
    df[col] = df[col].str.replace(r'\s+', ' ', regex=True).str.strip()

# Handle null values
null_counts = df.isnull().sum()
print("Null values per column:")
print(null_counts)
df.dropna(inplace=True)

# Extract date components from Hire date
df["day_name"] = df["Hire date"].dt.day_name()
df["month_name"] = df["Hire date"].dt.month_name()
df["year"] = df["Hire date"].dt.year
df["month"] = df["Hire date"].dt.month
df["day"] = df["Hire date"].dt.day
df["hour"] = df["Hire date"].dt.hour
df["minute"] = df["Hire date"].dt.minute
df["second"] = df["Hire date"].dt.second
df["quarter"] = df["Hire date"].dt.quarter

# Clean salary column
if df['Salary'].dtype == 'object':
    df['Salary'] = pd.to_numeric(df['Salary'].str.replace('EGP', '').str.replace(',', '').str.strip(), errors='coerce')
else:
    df['Salary'] = pd.to_numeric(df['Salary'], errors='coerce')

# Save cleaned data
df.to_excel("Cleaned_HR_Data.xlsx", index=False)

print("Data cleaning complete. Cleaned file saved as 'Cleaned_HR_Data.xlsx'.")
