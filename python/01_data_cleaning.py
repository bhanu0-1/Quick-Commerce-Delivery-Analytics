"""
Q-Commerce Delivery Operations & Pricing Analytics
Step 1: Data Cleaning

Input : quick_commerce_data_raw.csv  (1,000,000 rows, 13 columns)
Output: quick_commerce_data_cleaned.csv

Cleaning decisions (documented for case study):
  1. City typo fix          -> "Bengluru" -> "Bengaluru"
  2. City nulls (5.2%)      -> labelled "Unknown" (cannot be inferred; imputing
                                geography would fabricate data)
  3. Items_Count nulls (3.5%)-> imputed with category-level median (count field,
                                low-bias fill)
  4. Customer_Rating nulls (4.7%)        -> left as NULL
  5. Delivery_Partner_Rating nulls (10.4%)-> left as NULL
     (Ratings are not imputed. Filling them would bias downstream analyses
     such as delivery time vs. rating correlation. Aggregate functions like
     AVG() correctly ignore NULLs in SQL / Power BI.)
"""

import pandas as pd
import numpy as np

RAW_PATH = "/mnt/user-data/uploads/quick_commerce_data_raw.csv"
OUT_PATH = "/home/claude/qcommerce_project/quick_commerce_data_cleaned.csv"

def main():
    df = pd.read_csv(RAW_PATH)
    print(f"Loaded raw data: {df.shape[0]:,} rows, {df.shape[1]} columns")

    # --- 1. Fix city typo ---
    df["City"] = df["City"].replace({"Bengluru": "Bengaluru"})

    # --- 2. City nulls -> "Unknown" ---
    city_nulls_before = df["City"].isna().sum()
    df["City"] = df["City"].fillna("Unknown")

    # --- 3. Items_Count nulls -> category-level median ---
    items_nulls_before = df["Items_Count"].isna().sum()
    df["Items_Count"] = df.groupby("Product_Category")["Items_Count"].transform(
        lambda s: s.fillna(s.median())
    )
    df["Items_Count"] = df["Items_Count"].round().astype(int)

    # --- 4 & 5. Ratings -> leave as NULL (no action, just report) ---
    cust_rating_nulls = df["Customer_Rating"].isna().sum()
    partner_rating_nulls = df["Delivery_Partner_Rating"].isna().sum()

    # --- Data type / sanity cleanup ---
    df["Order_Value"] = df["Order_Value"].round(2)
    df["Delivery_Time_Min"] = df["Delivery_Time_Min"].round(1)
    df["Distance_Km"] = df["Distance_Km"].round(2)
    df["Discount_Applied"] = df["Discount_Applied"].astype(bool)

    # --- Report ---
    print("\n--- Cleaning summary ---")
    print(f"City nulls filled with 'Unknown'      : {city_nulls_before:,}")
    print(f"Items_Count nulls imputed (median)     : {items_nulls_before:,}")
    print(f"Customer_Rating left NULL               : {cust_rating_nulls:,}")
    print(f"Delivery_Partner_Rating left NULL       : {partner_rating_nulls:,}")
    print(f"Duplicate rows found                    : {df.duplicated().sum():,}")
    print(f"Final shape                             : {df.shape}")

    df.to_csv(OUT_PATH, index=False)
    print(f"\nSaved cleaned file to: {OUT_PATH}")

if __name__ == "__main__":
    main()
