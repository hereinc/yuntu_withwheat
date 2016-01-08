from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, func
from datetime import datetime, timedelta

Base = automap_base()
engine = create_engine("mysql://tableau:tableau@10.0.0.20:3306/ym")
Base.prepare(engine, reflect=True)
OrderItems = Base.classes.orders

session = Session(engine)

thirty_days_ago = datetime.now() - timedelta(days=30)

q = session.query(OrderItems).filter(OrderItems.pay_time >= thirty_days_ago).filter(OrderItems.order_status.in_(['PAID','RECEIVED']))
thirty_day_gmv = q.with_entities(func.sum(OrderItems.pay_price)).scalar()

print thirty_day_gmv/q.group_by(OrderItems.order_id).count()

print str(q.group_by(OrderItems.order_id).count())
