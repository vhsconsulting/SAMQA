create or replace package samqa.pc_deposit_reconcilation as
    procedure export_deposit_report (
        pv_file_name in varchar2,
        p_user_id    in number
    );

    procedure update_account;

    procedure reconcile_account;

end;
/


-- sqlcl_snapshot {"hash":"0db4a80d16ee831de4320b1b1e25ac3fad2095c4","type":"PACKAGE_SPEC","name":"PC_DEPOSIT_RECONCILATION","schemaName":"SAMQA","sxml":""}