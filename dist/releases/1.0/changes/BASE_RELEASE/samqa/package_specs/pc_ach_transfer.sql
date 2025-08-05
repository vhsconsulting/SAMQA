-- liquibase formatted sql
-- changeset SAMQA:1754374133983 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_ach_transfer.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_ach_transfer.sql:null:d8043bbc6efdc5c994908bc2747ef561c99f0c18:create

create or replace package samqa.pc_ach_transfer is
    g_contribution_limit number := 3250;
    procedure ins_ach_transfer (
        p_acc_id           in number,
        p_bank_acct_id     in number,
        p_transaction_type in varchar2,
        p_amount           in number default 0,
        p_fee_amount       in number default 0,
        p_transaction_date in date,
        p_reason_code      in number,
        p_status           in varchar2,
        p_user_id          in number,
        p_pay_code         in number default 5,
        x_transaction_id   out number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    );

    procedure upd_ach_transfer (
        p_transaction_id   in number,
        p_transaction_type in varchar2,
        p_amount           in number default 0,
        p_fee_amount       in number default 0,
        p_transaction_date in date,
        p_reason_code      in number,
        p_user_id          in number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    );

    procedure delete_ach_transfer (
        p_transaction_id in number,
        p_user_id        in number,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    );

    procedure cancel_ach_transfer (
        p_transaction_id in number,
        p_user_id        in number,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    );

    function get_pending_balance (
        p_acc_id      in number,
        p_end_date    in date,
        p_reason_code in number
    ) return number;

    procedure ins_ach_transfer_hrafsa (
        p_acc_id           in number,
        p_bank_acct_id     in number,
        p_transaction_type in varchar2,
        p_amount           in number default 0,
        p_fee_amount       in number default 0,
        p_transaction_date in date,
        p_reason_code      in number,
        p_status           in varchar2,
        p_user_id          in number,
        p_claim_id         in number,
        p_plan_type        in varchar2,
        p_pay_code         in number default 5,
        x_transaction_id   out number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    );

    function get_bank_acct_id (
        p_transaction_id in number
    ) return number;

    procedure void_invoice (
        p_invoice_id in number,
        p_user_id    in number
    );

    function is_pending_txn (
        p_transaction_id in number,
        p_acc_id         in number
    ) return varchar2;

    procedure reprocess_declines;

    function get_bankserv_pin (
        p_account_type in varchar2
    ) return varchar2;

    procedure update_ach_status (
        p_transaction_id   in number,
        p_ach_status       in varchar2,
        p_response_message in varchar2,
        x_error_message    out varchar2
    );

end pc_ach_transfer;
/

