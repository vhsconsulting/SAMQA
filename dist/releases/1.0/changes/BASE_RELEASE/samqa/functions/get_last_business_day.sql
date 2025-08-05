-- liquibase formatted sql
-- changeset SAMQA:1754373927711 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\get_last_business_day.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/get_last_business_day.sql:null:40938fa6a2f7764078f230ddd1fd6ec5fc0d72ce:create

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

