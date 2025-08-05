-- liquibase formatted sql
-- changeset SAMQA:1754374135803 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_deposit_reconcilation.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_deposit_reconcilation.sql:null:0db4a80d16ee831de4320b1b1e25ac3fad2095c4:create

create or replace package samqa.pc_deposit_reconcilation as
    procedure export_deposit_report (
        pv_file_name in varchar2,
        p_user_id    in number
    );

    procedure update_account;

    procedure reconcile_account;

end;
/

