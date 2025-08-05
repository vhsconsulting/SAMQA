-- liquibase formatted sql
-- changeset SAMQA:1754373951737 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\ora81pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/ora81pkg.sql:null:5971021e0a56f581a2ab07342677440c187f27f9:create

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

