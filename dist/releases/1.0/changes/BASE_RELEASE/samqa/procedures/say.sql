-- liquibase formatted sql
-- changeset SAMQA:1754374146094 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\say.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/say.sql:null:8896917707f44b6d566ce70bf4aa4ff181f637b1:create

create or replace procedure samqa.say (
    str in varchar2
) is
begin
    dbms_output.put_line(str);
exception
    when others then
        dbms_output.put_line(sqlerrm);
end say;
/

