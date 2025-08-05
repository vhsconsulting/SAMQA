create or replace package samqa.pc_debit is
    procedure update_current_acct_balance;

    procedure update_audit_card_value;

    procedure update_days_card_settlements;

    procedure update_audit_card_settlements;

end pc_debit;
/


-- sqlcl_snapshot {"hash":"1b5c88b00721507e27d2caa1a007e7b84331caf3","type":"PACKAGE_SPEC","name":"PC_DEBIT","schemaName":"SAMQA","sxml":""}