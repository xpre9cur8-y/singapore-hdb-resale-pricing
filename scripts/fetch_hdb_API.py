import requests
import pandas as pd
import time

DATASET_ID = "d_8b84c4ee58e3cfc0ece0d773c8ca6abc"
URL = f"https://data.gov.sg/api/action/datastore_search?resource_id={DATASET_ID}&limit=10000"

print("Fetching data from data.gov.sg...")
all_records = []
offset = 0

while True:
    try:
        response = requests.get(URL + f"&offset={offset}", timeout=30)
        data = response.json()

        if "result" not in data:
            print(f"Unexpected response at offset {offset}, retrying in 5s...")
            time.sleep(5)
            continue

        records = data["result"]["records"]

        if not records:
            break

        all_records.extend(records)
        offset += 10000
        print(f"  Fetched {len(all_records)} rows so far...")
        time.sleep(1)  # small delay to avoid rate limiting

    except Exception as e:
        print(f"Error at offset {offset}: {e}, retrying in 5s...")
        time.sleep(5)

df = pd.DataFrame(all_records)
df.to_csv("../data/hdb_resale.csv", index=False)
print(f"Done. {len(df)} rows saved to data/hdb_resale.csv")
print(df.head())
print(df.dtypes)
