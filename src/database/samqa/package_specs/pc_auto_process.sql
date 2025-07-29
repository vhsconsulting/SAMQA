create or replace package samqa.pc_auto_process as
    procedure bank_serv_deposits (
        p_date in varchar2
    );

    procedure card_balance_reconcile (
        p_date in varchar2 default null
    );

    procedure assign_broker_to_account;

    procedure fix_plan_code;

    procedure fix_date;

    procedure upload_debit_card_error;

    procedure update_card_status;

    procedure process_pending_edeposit;

    procedure post_ach_deposits (
        p_transaction_id in number
    );

    procedure generate_ach_upload;

    procedure process_broker_commissions;

    procedure inactivate_scheduler_detail;

    procedure refresh_employer_balance_mv;
	-- Below Procedures added by Swamy for Ticket#7723
    procedure nacha_file;
    --PROCEDURE GENERATE_NACHA_FILE(P_ACCOUNT_TYPE IN VARCHAR2 DEFAULT NULL);
    procedure process_nacha_file;
    -- Swamy for Cobrapoint 30/11/2022
    procedure confirm_employer_refund (
        p_transaction_id in number
    );

    procedure generate_nacha_file_employee (
        p_account_type in varchar2 default null,
        p_file_name    out varchar2
    );   -- For Server Migration by Swamy 06/10/2023
    procedure generate_nacha_file_employer (
        p_account_type in varchar2 default null,
        p_file_name    out varchar2
    );   -- For Server Migration by Swamy 06/10/2023
    procedure generate_nacha_file_fee (
        p_account_type in varchar2 default null,
        p_file_name    out varchar2
    );   -- For Server Migration by Swamy 06/10/2023
    procedure generate_nacha_file_for_employee_payment (
        p_account_type in varchar2 default null,
        p_file_name    out varchar2
    );   -- Added by Joshi for 12748- Sprint 59: ACH Pull for FSA/HRA Claims
end;
/


-- sqlcl_snapshot {"hash":"8bf54f85bcf6d69103607c9689482184c6f6cd8e","type":"PACKAGE_SPEC","name":"PC_AUTO_PROCESS","schemaName":"SAMQA","sxml":""}