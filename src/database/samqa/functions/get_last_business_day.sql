create or replace function samqa.get_last_business_day (
    p_date in date
) return date as
begin
    for x in (
        select
            lastbusinessday
        from
            monthly_v
        where
            period_date = trunc(p_date, 'MM')
    ) loop
        return x.lastbusinessday;
    end loop;
end get_last_business_day;
/


-- sqlcl_snapshot {"hash":"40938fa6a2f7764078f230ddd1fd6ec5fc0d72ce","type":"FUNCTION","name":"GET_LAST_BUSINESS_DAY","schemaName":"SAMQA","sxml":""}