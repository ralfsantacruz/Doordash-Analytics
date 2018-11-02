import pandas as pd
import sqlalchemy

# Create connection to SQL database called Doordash
engine = sqlalchemy.create_engine("mysql+pymysql://root:@localhost:3386/Doordash")


# Create query
query = '''SELECT sub2.effective_hourly_rate, sub2.dasher_email
FROM (
	SELECT sub1.total/sub1.hours_worked as "effective_hourly_rate", 
	sub1.email as "dasher_email",
	sub1.dasher_id as "dasher_id"
	FROM (
		SELECT sum(d.total_pay) as "total",
		sum(datediff(second,d.dash_start_time,d.dash_end_time)/3600.0)) as "hours_worked",
		da.email_address as "email",
		d.dasher_id
		FROM Dash d
		JOIN Dasher da
		ON (d.dasher_id=da.id)
		WHERE dash_end_time BETWEEN NOW() - INTERVAL 30 DAY AND NOW()
		GROUP BY dasher_id
		)
		sub1
	order by sub1.total/sub1.hours_worked desc
    ) sub2'''

# Execute query and save returned result as a pandas dataframe
df = pd.read_sql_query(query, engine)

rate = "sub2.effective_hourly_rate"

# Equivalent of SELECT * FROM <table> WHERE <rate> < <median_rate>
df = df[(df[rate] < df[rate].median())]

# Display the dataframe
df.head()

