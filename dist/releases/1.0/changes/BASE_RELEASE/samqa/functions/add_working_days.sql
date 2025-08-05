-- liquibase formatted sql
-- changeset SAMQA:1754373926849 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\add_working_days.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/add_working_days.sql:null:188391f31f0061cc8cb573051d771d7721315e99:create

create or replace function samqa.add_working_days (
    p_days in number,
    p_dt   in date default trunc(sysdate)
) return date as
    v_weeks number;
    v_adj   number;
begin
    v_weeks := trunc(p_days / 5);
    if to_number ( to_char(p_dt, 'D') ) + mod(p_days, 5) >= 7 then
        v_adj := 2;
    else
        v_adj := 0;
    end if;

    return p_dt + 7 * v_weeks + v_adj + mod(p_days, 5);
end add_working_days;
/

