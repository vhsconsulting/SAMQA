-- liquibase formatted sql
-- changeset SAMQA:1754374135440 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_debit.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_debit.sql:null:1b5c88b00721507e27d2caa1a007e7b84331caf3:create

create or replace package samqa.pc_debit is
    procedure update_current_acct_balance;

    procedure update_audit_card_value;

    procedure update_days_card_settlements;

    procedure update_audit_card_settlements;

end pc_debit;
/

