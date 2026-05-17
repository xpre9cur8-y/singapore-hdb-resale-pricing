# singapore-hdb-resale-pricing
Study of Singapore HDB resale transactions using API ingestion and SQL to identify pricing patterns and hotspots

## Project Overview

Using data from the Housing Development Board's official API to form four analytical SQL queries that reveal patterns and trade-offs in the market. The findings are relevant for buyers deciding between towns, policy analysts tracking price momentum, and anyone curious about what actually drives HDB prices.

### Description

The analysis covers: <br>
Data quality checks — validating the dataset for nulls, price outliers, and sample size before trusting any findings

High floor premium — quantifying how much buyers actually pay for each floor band, and whether it justifies the cost <br>
Town appreciation trends — identifying which HDB towns are accelerating in price growth vs. plateauing after years of gains
Lease decay impact — measuring how remaining lease length affects resale prices, and where the market draws the line <br>
Million-dollar flat distribution — revealing which towns dominate the million-dollar market and whether it's spreading or concentrating <br>
Value analysis — finding the best space-per-dollar flat type in each town, not just the cheapest units <br>

## Data Scraping

**HDB Resale Flat Prices** from [data.gov.sg](https://data.gov.sg/datasets/d_8b84c4ee58e3cfc0ece0d773c8ca6abc) <br>
180,000+ transactions from 2017–present

The project involved structured ETL to prepare the dataset:

Fetching JSON responses from the data.gov.sg API via Python <br>
Converting API responses into a pandas DataFrame and saving as CSV

## Key Findings

High Floor Myth — A 25th-floor 3-room costs 18% more than ground floor, but only 2% more space per dollar. Floors 19-24 are the sweet spot. <br>
Town Momentum Matters — Established towns (Bishan, Central) show slowing growth (8% YoY). Emerging towns (Punggol, Jurong West) show acceleration (18% YoY). Tells you where the market is heading. <br>
Million-Dollar Concentration — 80% of million-dollar transactions in three towns. New towns entering slowly (Punggol 2022).  <br>

## Usage

Browse the SQL files in the repository to view and run the analysis queries. You can modify the queries to explore different insights from the dataset such as different flat types.
