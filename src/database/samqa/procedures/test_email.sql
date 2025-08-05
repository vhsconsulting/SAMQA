create or replace procedure samqa.test_email as
begin
    pc_check_process.send_email_on_checks;
end;
/


-- sqlcl_snapshot {"hash":"20e67eb006b53405efca973f9d52957d23691afd","type":"PROCEDURE","name":"TEST_EMAIL","schemaName":"SAMQA","sxml":""}