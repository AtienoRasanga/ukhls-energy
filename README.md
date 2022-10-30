# ukhls-energy

**Multiplicative Model for Domestic Energy Consumption**

File Types

\*ipynb - Raw Jupiter Notebooks file

Data Files

Source - https://www.gov.uk/government/statistics/national-energy-efficiency-data-framework-need-consumption-data-tables-2021

\* need\_consumption\_eng.xlsx - Consumption tables downloaded from NEED website for England & Wales. 

\* need\_consumption\_scot.xlsx - Consumption tables downloaded from NEED website for Scotland

England & Wales Consumption Tables Excel Sheets

Table\_3 - Gas consumption by number of bedrooms

Table\_4 - Electricity consumption by number of bedrooms

Table\_9 - Gas consumption by tenure

Table\_10 - Electricity consumption by tenure

Table\_11 - Gas consumption by income

Table\_12 - Electricity consumption by income

Table\_13 - Gas consumption by number of adults

Table\_14 - Electricity consumption by number of adults

Table\_15 - Gas consumption by region

Table\_16 - Electricity consumption by region

Scotland Consumption Tables Excel Sheets

Table\_1 - Gas consumption by number of bedrooms

Table\_2 - Electricity consumption by number of bedrooms

Table\_7 - Gas consumption by tenure

Table\_8 - Electricity consumption by tenure

Table\_9 - Gas consumption by income

Table\_10 - Electricity consumption by income

Table\_11 - Gas consumption by number of adults

Table\_12 - Electricity consumption by number of adults

\* Each sheet has sample sizes , mean consumption & median consumptions for each year 


\1. Total Consumption

Calculate the total consumption for each year, we assume that all the consumption tables are derived from the same underlying raw data (same households), and therefore the total consumptions for each factor being considered should be equal. 

\2. Weight

We calculate the contribution of each factor to the average domestic consumption by calculating the ratio of each characteristic for a factor to the average consumption and then calculate the product of the combination of weights. 

\3. Model Consumption

Finally model the consumption for every combination of characteristic by calculating the product of weights and the average consumption. 


