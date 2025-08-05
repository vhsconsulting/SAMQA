-- liquibase formatted sql
-- changeset SAMQA:1754373926835 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\add_weeks.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/add_weeks.sql:null:27911453b38c17b42749f2eff3c9adae3be6db04:create

create or replace function samqa.add_weeks (
    in_dt     in date,
    num_weeks in integer
) return date is
    out_dt date;
begin
    select
        in_dt + ( num_weeks * 7 )
    into out_dt
    from
        dual;

    return ( out_dt );
end;
/

