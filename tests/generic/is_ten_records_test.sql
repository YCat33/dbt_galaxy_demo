{% test not_ten_records(model, column_name) %}

with validation as (
    select {{ column_name }} as season,
    count(*) as num_records
    from {{ model }}
    group by {{ column_name }}
    having count(*) != 10
),

validation_errors as (
    select season from validation 
)

select * from validation_errors

{% endtest %}