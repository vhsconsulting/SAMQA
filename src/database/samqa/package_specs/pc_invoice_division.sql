create or replace package samqa.pc_invoice_division as
    procedure generate_invoice (
        p_start_date    in date,
        p_end_date      in date,
        p_billing_date  in date default sysdate,
        p_entrp_id      in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

    procedure process_hra_fsa_invoice (
        p_start_date    in date,
        p_end_date      in date,
        p_billing_date  in date default sysdate,
        p_entrp_id      in number,
        p_division_code in varchar2,
        p_batch_number  in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

    procedure process_hsa_invoice (
        p_start_date    in date,
        p_end_date      in date,
        p_billing_date  in date default sysdate,
        p_entrp_id      in number,
        p_batch_number  in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

    procedure proc_hsa_active_dist (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    );

    procedure proc_hsa_distribution_summary (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    );

    procedure proc_active_dist (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    );

    procedure proc_runout_dist (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    );

    procedure proc_term_dist (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    );

    procedure proc_term_credit (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    );

    procedure proc_debit_card_charge_dist (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    );

    procedure proc_debit_card_issuance_dist (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    );

    procedure proc_lost_stolen_dist (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    );

    procedure proc_active_adj_dist (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    );

    procedure proc_eob_charge_dist (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    );

    procedure proc_sf_ord_dist (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    );

    procedure insert_invoice_line (
        p_invoice_id        in number,
        p_invoice_line_type in varchar2 default 'INVOICE_LINE',
        p_rate_code         in varchar2,
        p_description       in varchar2,
        p_quantity          in number,
        p_no_of_months      in number,
        p_rate_cost         in number,
        p_total_cost        in number default null,
        p_batch_number      in number,
        x_invoice_line_id   out number
    );

    procedure proc_distribution_summary (
        p_invoice_id    in number,
        p_entrp_id      in number,
        p_division_code in varchar2,
        p_start_date    in date,
        p_end_date      in date
    );

    procedure approve_invoice (
        p_invoice_id in number,
        p_user_id    in number
    );

    procedure apply_invoice_payment (
        p_batch_number       in number,
        p_transaction_number in varchar2,
        p_transaction_date   in date,
        p_payment_amount     in number,
        p_acc_id             in number,
        p_invoice_id         in number,
        p_note               in varchar2,
        p_bank_account       in number,
        p_user_id            in number,
        p_pay_method         in varchar2,
        p_plan_type          in varchar2,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    );

    procedure post_invoice (
        p_transaction_id in number
    );

    procedure post_check_invoice (
        p_invoice_id     in number,
        p_check_number   in varchar2,
        p_check_amount   in number,
        p_payment_method in varchar2,
        p_check_date     in date,
        p_user_id        in number
    );

    function get_actual_balance (
        p_acc_id    in number,
        p_plan_type in varchar2,
        p_fee_date  in date
    ) return number;

    procedure void_invoice (
        p_invoice_id in number,
        p_user_id    in number
    );

    procedure update_invoice_amount (
        p_invoice_id in number,
        p_user_id    in number
    );

    procedure generate_monthly_invoice;

end pc_invoice_division;
/


-- sqlcl_snapshot {"hash":"356185a5865217c5946f8bc43f4602ade07fe35e","type":"PACKAGE_SPEC","name":"PC_INVOICE_DIVISION","schemaName":"SAMQA","sxml":""}