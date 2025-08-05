-- liquibase formatted sql
-- changeset SAMQA:1754373927038 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\date_or_null.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/date_or_null.sql:null:455181cd99257ce2b1b2f60c89561640253041f3:create

create or replace function samqa.date_or_null (
    p_date in varchar2
) return date as
begin
    return to_date ( p_date, 'YYYY-MM-DD' );
exception
    when others then
        return null;
end date_or_null;
/

