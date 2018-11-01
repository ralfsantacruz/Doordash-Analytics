-- question 1
SELECT dayofweek(sub.dates) as "day of week", avg(sub.total/sub.difference) as "avg_hourly_rate"
FROM (
	SELECT dash_end_time as "dates",
    sum(total_pay) as "total",
    sum(datediff(hour, dash_end_time,dash_start_time))) as "hours_worked"
    FROM Dash
    GROUP BY dash_end_time
    )
    sub
GROUP BY dayofweek(sub.dates);

-- In the first query, we are taking the sum of the total pay for each entry and taking the difference in hours for when the shift
-- was started and ended to calculate the total hours worked. 
-- The sums are grouped by the dash_end_time to get the totals for each date. 
-- The outer query selects the average of the hourly rates for each day of the week and groups them by the number of day that corresponds to the day of the week.

-- question 2
SELECT sum(d.total_pay)/3 as "total pay" , 
da.submarket_id as "submarket_id"
FROM Dash d
JOIN Dasher da
ON (d.dasher_id=da.id)
WHERE hour(dash_start_time) >= 11 and hour(dash_end_time) <= 14
GROUP BY d.dasher_id
HAVING submarket_id = 3;

-- Here we are joining both the Dash and Dasher tables to be able to extract information on the submarket_id and the earnings per hours for lunch.
-- We divide the sum of the total pay by 3 since we are calculating from 11am to 2pm (3 hours) to obtain our hourly rate.
-- We specify criteria for the times we would like to look at (11am and 2pm), group everything by the dasher_id and then we make sure we filter for the submarket_id at the end. 


-- question 3
SELECT sub2.effective_hourly_rate, sub2.dasher_email
FROM (
	SELECT sub1.total/sub1.hours_worked as "effective_hourly_rate", 
	sub1.email as "dasher_email",
	sub1.dasher_id as "dasher_id"
	FROM (
		SELECT sum(d.total_pay) as "total",
		sum(datediff(hour,d.dash_start_time,d.dash_end_time))) as "hours_worked",
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
    ) sub2
WHERE median_val IN (
SELECT AVG(dd.sub2.effective_hourly_rate) as median_val
FROM (
SELECT d.val, @rownum:=@rownum+1 as `row_number`, @total_rows:=@rownum
  FROM data d, (SELECT @rownum:=0) r
  WHERE d.val is NOT NULL
  ORDER BY d.val
) as dd
WHERE dd.row_number IN ( FLOOR((@total_rows+1)/2), FLOOR((@total_rows+2)/2) ));

--This one was quite challenging... My logic goes as follows:
--Obtain the total pay for each dasher for the last 30 days
--Obtain the total hours worked for each dasher for the last 30 days
--Divide the total pay by the total hours worked to obtain the effective hourly rate for each dasher and group by each dasher_id for the last 30 days
--Here it gets a bit tricky as mySQL does not have a built in function to calculate the median (50th percentile), but my logic was to write
--a function that stored the median_val and then write a query that goes as such:

-- SELECT effective_hourly_rate, dasher_email
-- FROM table
-- WHERE effective_hourly_rate < median

--There are other ways to programmatically obtain the same result if one was to use different tools such as Python/Pandas as well with ease.
--My approach would be to perform the same calculations and take advantage of Pandas's built-in median function to create a conditional that will
--return all of the hourly rates that are lower than the median.