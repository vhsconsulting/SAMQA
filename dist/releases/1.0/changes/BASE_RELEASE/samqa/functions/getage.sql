-- liquibase formatted sql
-- changeset SAMQA:1754373928036 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\getage.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/getage.sql:null:1c22b5e8b516406a7868aa28e4dab5a65240416a:create

create or replace function samqa.getage (
    p_date in date
) return number is
begin
    return floor(months_between(current_date, p_date) / 12);
end;
/

