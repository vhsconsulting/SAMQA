create or replace package body samqa.ora81pkg is
   /* ---------------------------- PUBLIC MODULES -------------------------- */
    procedure pl (
        line_in in varchar2
    ) is
        pragma autonomous_transaction;
    begin
        insert into trc_log (
            username,
            curdate,
            line
        ) values ( user,
                   sysdate,
                   line_in );

        commit;
    end pl;

end ora81pkg;
/


-- sqlcl_snapshot {"hash":"5971021e0a56f581a2ab07342677440c187f27f9","type":"PACKAGE_BODY","name":"ORA81PKG","schemaName":"SAMQA","sxml":""}