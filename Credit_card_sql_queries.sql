select * from [dbo].[credit_card_transcations$]

/*1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends*/

with cte as
(
select city,sum(amount) as total
from [dbo].[credit_card_transcations$]
group by city
),

cte1 as
(select sum(amount) as total_transaction
from [dbo].[credit_card_transcations$])


select top 5 city,total, round((total*1.0/total_transaction)*100,2) as percentage
from cte,cte1
order by total desc


/* 2- write a query to print highest spend month and amount spent in that month for each card type*/
with cte as
(
select card_type,DATEPART(year,transaction_Date) as year_of_transaction, DATEPART(month,transaction_date) as month_of_transaction, sum(amount) as amount_spend
from [dbo].[credit_card_transcations$]
group by card_type,DATEPART(year,transaction_Date),DATEPART(month,transaction_date)
)
,cte1 as
(
select card_type,month_of_transaction,amount_spend,
rank() over(partition by card_type order by amount_spend desc) as rnk
from cte
)

select card_type,month_of_transaction,amount_spend
from cte1
where rnk=1


/* 3- write a query to print the transaction details(all columns from the table) for each card type when
it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)*/

select * from [dbo].[credit_card_transcations$]

with cte as
(
select transaction_id,city,transaction_date,card_type,exp_type,gender,
sum(amount) over(partition by card_type order by transaction_id,transaction_date) as total_spend
from [dbo].[credit_card_transcations$]
)

select *
from cte
where total_spend>1000000





/*4- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)*/

select * 
from [dbo].[credit_card_transcations$]

with cte as
(
select city,exp_type,sum(amount) as total_spend
from [dbo].[credit_card_transcations$]
group by city,exp_type
)

, cte1 as
(
select city,exp_type,total_spend,
rank() over(partition by city order by total_spend desc) as highest_expense,
rank() over(partition by city order by total_spend asc) as lowest_expense
from cte
)


select city, max(case when lowest_expense=1 then exp_type end) as lowest_expense_type,
min(case when highest_expense=1 then exp_type end) as highest_Expense_type
from cte1
group by city



/* 5- write a query to find percentage contribution of spends by females for each expense type*/
with cte as
(
select exp_type,sum(amount) as total_spend
from [dbo].[credit_card_transcations$]
where gender='F'
group by exp_type
),
cte1 as
(
select sum(amount) as total
from [dbo].[credit_card_transcations$]
group by exp_type
)

select exp_type,total_spend/total
from cte,cte1
group by exp_type

select exp_type,
sum(case when gender='F' then amount else 0 end)*1.0/sum(amount) as female_spend
from [dbo].[credit_card_transcations$]
group by exp_type

/*6- which card and expense type combination saw highest month over month growth in Jan-2014*/
with cte as
(
select card_type,exp_type,sum(amount) as total_spend,
DATEPART(month,transaction_date) as month,DATEPART(year,transaction_date) as year
from [dbo].[credit_card_transcations$]
group by card_type,exp_type,
DATEPART(month,transaction_date) ,DATEPART(year,transaction_date) 
),
cte1 as
(select *,
lag(total_spend) over(partition by card_type,exp_type order by year,month) as prev
from cte
)

select top 1 *,(total_Spend-prev)*1.0/prev as mom_growth
from cte1
where year=2014 and month=1
order by mom_growth desc