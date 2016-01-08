import mysql.connector
import pandas as pd
from datetime import datetime, timedelta
import requests
import json

cnx = mysql.connector.connect(user='tableau', password='tableau',
                              host='10.0.0.20',
                              database='ym')

start_time = datetime.now() - timedelta(days=200)
df = pd.read_sql('SELECT * FROM orders WHERE pay_time >= "%s"' % start_time, con=cnx)

cnx.close()

df['pay_time'] = pd.to_datetime(df['pay_time'])
df.index = df['pay_time']
del df['pay_time']

#### average order size last 30 days
paid_or_received = df[df['order_status'].isin(['PAID','RECEIVED'])]

last_30_days = paid_or_received[str((datetime.now()-30*timedelta(1)).date()):]
average_order_30_days = (last_30_days['pay_price'].sum()/last_30_days['order_id'].nunique()).item()

# orders_by_month = paid_or_received.groupby(pd.TimeGrouper("M"))
orders_by_month = paid_or_received.groupby(paid_or_received.index.date)

total_by_month = orders_by_month['pay_price'].sum()
order_count_by_month = orders_by_month['order_id'].nunique()
average_order_by_month = total_by_month/order_count_by_month

history = average_order_by_month[-6:].tolist()
history[-1] = average_order_30_days

r = requests.post("https://push.geckoboard.com/v1/send/172028-0e08f4be-70cb-482b-918c-6b7074082d3f",
    data = json.dumps({"api_key": "f29b8d438283af1e366df92b2563f979", "data": {
        "item": [
        {
          "value": average_order_30_days
        }, history
    ]}}))

print(r.text)
print(history)


