-- liquibase formatted sql
-- changeset SAMQA:1754373927309 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\get_biweekly.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/get_biweekly.sql:null:85d76816bdc175b42c4dd4f91e5032853b0bb1a8:create

create or replace function samqa.get_biweekly (
    in_dt     in date,
    num_weeks in integer
) return date is
    out_dt date;
begin
    select
        in_dt + ( num_weeks * 14 )
    into out_dt
    from
        dual;

    return ( out_dt );
end;
/

