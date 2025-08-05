create or replace procedure samqa.purge_check (
    p_check_number in number
) is
    l_check_number number;
begin
    update checks
    set
        status = 'PURGED'
    where
        check_number = p_check_number;

end;
/


-- sqlcl_snapshot {"hash":"3da6d601eb19fceacd13daef131fcd240589a729","type":"PROCEDURE","name":"PURGE_CHECK","schemaName":"SAMQA","sxml":""}