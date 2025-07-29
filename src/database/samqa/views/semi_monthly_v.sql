create or replace force editionable view samqa.semi_monthly_v (
    period_date
) as
    select
        case
            when to_char(calc_day, 'D') = 7 then
                calc_day + 2
            when to_char(calc_day, 'D') = 1 then
                calc_day + 1
            else
                calc_day
        end period_date
    from
        (
            select
                rownum,
                ( trunc(sysdate, 'YYYY') - 1 ) + rownum calc_day
            from
                all_objects
            where
                rownum < ( trunc(
                    add_months(sysdate, 12),
                    'YY'
                ) ) - ( trunc(sysdate, 'YY') - 1 )
        )
    where
        to_char(calc_day, 'DD') = '15'
        or calc_day = trunc(calc_day, 'MM');


-- sqlcl_snapshot {"hash":"6f9933015f4edec027f68cc15a96db4cd59b47be","type":"VIEW","name":"SEMI_MONTHLY_V","schemaName":"SAMQA","sxml":""}