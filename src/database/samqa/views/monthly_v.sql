create or replace force editionable view samqa.monthly_v (
    period_date,
    firstdayofweek,
    firstbusinessday,
    firstbusinessdayofweek,
    lastday,
    lastdayofweek,
    lastbusinessday,
    lastbusinessdayofweek,
    current_month
) as
    with dateparam as -- Common Table expression to cache all dates in current year
     (
        select
            trunc(sysdate, 'YYYY') + level - 1 as mydate
        from
            dual
        connect by
            trunc(trunc(sysdate, 'YYYY') + level - 1,
                  'YYYY') = trunc(sysdate, 'YYYY')
    )
    select distinct
        add_months(last_day(mydate) + 1,
                   -1)        as period_date,
        to_char(
            add_months(last_day(mydate) + 1,
                       -1),
            'DAY'
        )                     as firstdayofweek,
        case
            when to_char(
                add_months(last_day(mydate) + 1,
                           -1),
                'D'
            ) = 1 then
                last_day(mydate) + 1 -- add one day if first day is Sunday
            when to_char(
                add_months(last_day(mydate) + 1,
                           -1),
                'D'
            ) = 7 then
                last_day(mydate) + 2 -- add two days if first day is Saturday
            else
                add_months(last_day(mydate) + 1,
                           -1)
        end                   as firstbusinessday,
        case
            when to_char(
                add_months(last_day(mydate) + 1,
                           -1),
                'D'
            ) = 1 then
                to_char(add_months(last_day(mydate) + 1,
                                   -1) + 1,
                        'DAY')
            when to_char(
                add_months(last_day(mydate) + 1,
                           -1),
                'D'
            ) = 7 then
                to_char(add_months(last_day(mydate) + 1,
                                   -1) + 2,
                        'DAY')
            else
                to_char(
                    add_months(last_day(mydate) + 1,
                               -1),
                    'DAY'
                )
        end                   as firstbusinessdayofweek,
        last_day(mydate)      as lastday,
        to_char(
            last_day(mydate),
            'DAY'
        )                     as lastdayofweek,
        case
            when to_char(
                last_day(mydate),
                'D'
            ) = 7 then
                last_day(mydate) - 1 -- reduce one day if last day is Saturday
            when to_char(
                last_day(mydate),
                'D'
            ) = 1 then
                last_day(mydate) - 2 -- reduce two days if last day is Sunday
            else
                last_day(mydate)
        end                   as lastbusinessday,
        case
            when to_char(
                last_day(mydate),
                'D'
            ) = 7 then
                to_char(last_day(mydate) - 1,
                        'DAY')
            when to_char(
                last_day(mydate),
                'D'
            ) = 1 then
                to_char(last_day(mydate) - 2,
                        'DAY')
            else
                to_char(
                    last_day(mydate),
                    'DAY'
                )
        end                   as lastbusinessdayofweek,
        to_char(mydate, 'MM') current_month
    from
        dateparam
    order by
        1;


-- sqlcl_snapshot {"hash":"8682fe45ba2c76a826b5cea6c134fd6268e0507b","type":"VIEW","name":"MONTHLY_V","schemaName":"SAMQA","sxml":""}