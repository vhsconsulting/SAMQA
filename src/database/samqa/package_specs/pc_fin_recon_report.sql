create or replace package samqa.pc_fin_recon_report as
    type transaction_row_t is record (
            name             varchar2(255),
            acc_num          varchar2(255),
            acc_id           number,
            transaction_date varchar2(255),
            reason_code      varchar2(255),
            reason_name      varchar2(255),
            amount           varchar2(255),
            fraud_flag       varchar2(1),
            private_label    varchar2(255),
            account_status   varchar2(255),
            teamster         varchar2(1),
            check_number     varchar2(255),
            listbill         number,
            salesrep_name    varchar2(255),
            employer_name    varchar2(100)
    ); -- Added by Joshi fpr #12215

    type transaction_t is
        table of transaction_row_t;
    function get_receipt_amount (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number;

    function get_receipt_details (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return transaction_t
        pipelined
        deterministic;

    function get_incomp_receipt (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number;

    function get_incomp_receipt_details (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return transaction_t
        pipelined
        deterministic;

    function get_fraud_receipt (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number;

    function get_fraud_receipt_details (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return transaction_t
        pipelined
        deterministic;

    function get_prev_adj_receipt (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number;

    function get_prev_adj_receipt_details (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return transaction_t
        pipelined
        deterministic;

    function get_interest (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number;

    function get_interest_details (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return transaction_t
        pipelined
        deterministic;

    function get_unposted_er_receipt (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number;

    function get_unposted_er_details (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return transaction_t
        pipelined
        deterministic;

    function get_fees (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number;

    function get_fees_details (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return transaction_t
        pipelined
        deterministic;

    function get_payment (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number;

    function get_payment_details (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return transaction_t
        pipelined
        deterministic;

    function get_er_refund (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number;

    function get_er_refund_details (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return transaction_t
        pipelined
        deterministic;

    function get_balance (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number;

    function get_beg_balance (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number;

    procedure get_ending_balance_details (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_start_date   in date,
        p_end_date     in date
    );

    function get_hsa_balance_details (
        p_acc_num  in varchar2,
        p_end_date in date
    ) return transaction_t
        pipelined
        deterministic;

    procedure send_balance_report (
        p_start_date in date,
        p_end_date   in date,
        x_file_name  out varchar2,
        x_subject    out varchar2
    );

    procedure send_cobra_balance_report (
        p_end_date  in date,
        x_file_name out varchar2,
        x_subject   out varchar2
    );

    procedure send_unposted_er_report (
        p_start_date in date,
        p_end_date   in date,
        x_file_name  out varchar2,
        x_subject    out varchar2
    );

    procedure send_er_receipt_prev_report (
        p_start_date in date,
        p_end_date   in date,
        x_file_name  out varchar2,
        x_subject    out varchar2
    );

    procedure send_ee_income_prev_report (
        p_start_date in date,
        p_end_date   in date,
        x_file_name  out varchar2,
        x_subject    out varchar2
    );

    procedure send_er_payment_prev_report (
        p_start_date in date,
        p_end_date   in date,
        x_file_name  out varchar2,
        x_subject    out varchar2
    );

    procedure send_ee_payment_prev_report (
        p_start_date in date,
        p_end_date   in date,
        x_file_name  out varchar2,
        x_subject    out varchar2
    );

end pc_fin_recon_report;
/


-- sqlcl_snapshot {"hash":"cf2aa1d507843acb88096be9821cabc49b35e514","type":"PACKAGE_SPEC","name":"PC_FIN_RECON_REPORT","schemaName":"SAMQA","sxml":""}