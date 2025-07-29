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


-- sqlcl_snapshot {"hash":"8896917707f44b6d566ce70bf4aa4ff181f637b1","type":"PROCEDURE","name":"SAY","schemaName":"SAMQA","sxml":""}