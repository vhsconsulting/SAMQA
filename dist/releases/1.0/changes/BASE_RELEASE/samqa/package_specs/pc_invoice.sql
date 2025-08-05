-- liquibase formatted sql
-- changeset SAMQA:1754374138577 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_invoice.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_invoice.sql:null:8ae81cdaedb9bf35fbcb858a78bc9743c80f0604:create

create or replace package samqa.pc_invoice as
    type varchar2_tbl is
        table of varchar2(3200) index by binary_integer;
    g_credit_card_fee number :=.03;
    type get_invoice_t is record (
            paid_amount number,
            bal_due     number,
            total_due   number
    );
    type ret_get_invoice_t is
        table of get_invoice_t;
    type account_rec is record (
            invoice_upload_id number,
            acc_num           varchar2(20),
            acc_id            number,
            entrp_id          number,
            rate_plan_id      number,
            bank_acct_id      number
    );
    type account_rec_t is
        table of account_rec;
    type invoice_upload_rec is record (
            acc_id             number,
            acc_num            varchar2(20),
            account_type       varchar2(30),
            entrp_id           number,
            rate_plan_id       number,
            invoice_param_id   number,
            rate_code          varchar2(30),
            reason_name        varchar2(100),
            bank_acct_id       number,
            invoice_date       date,
            start_date         date,
            end_date           date,
            invoice_amount     number,
            invoice_type       varchar2(100),
            payment_term       varchar2(255),
            payment_method     varchar2(255),
            billing_name       varchar2(255),
            billing_attn       varchar2(255),
            billing_address    varchar2(255),
            billing_city       varchar2(255),
            billing_zip        varchar2(255),
            billing_state      varchar2(255),
            created_by         number,
            invoice_upload_id  number,
            error_status       varchar2(1),
            error_message      varchar2(3000),
            last_invoiced_date date
    );
    type invoice_upload_rec_t is
        table of invoice_upload_rec;

-- Added by Joshi 12255 
    type invoice_creditcard_info_rec is record (
            invoice_id       number,
            invoice_amount   number,
            credit_card_fee  number,
            total_pay_amount number
    );
    type invoice_creditcard_info_t is
        table of invoice_creditcard_info_rec;
    procedure generate_invoice (
        p_start_date    in date,
        p_end_date      in date,
        p_billing_date  in date default sysdate,
        p_entrp_id      in number,
        p_account_type  in varchar2 default null,
        x_error_status  out varchar2,
        x_error_message out varchar2,
        p_invoice_type  in varchar2 default null,
        p_division_code in varchar2 default null,
        x_batch_number  out number
    );

    procedure process_hra_fsa_invoice (
        p_start_date    in date,
        p_end_date      in date,
        p_billing_date  in date default sysdate,
        p_entrp_id      in number,
        p_batch_number  in number,
        x_error_status  out varchar2,
        x_error_message out varchar2,
        p_invoice_freq  in varchar2 default 'MONTHLY'
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

    procedure process_pop_erisa_5500_inv (
        p_start_date        in date,
        p_end_date          in date,
        p_billing_date      in date default sysdate,
        p_entrp_id          in number,
        p_batch_number      in number,
        p_invoice_frequency varchar2 default null,
        x_error_status      out varchar2,
        x_error_message     out varchar2
    );

    procedure proc_hsa_active_dist (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    );

    procedure proc_hsa_distribution_summary (
        p_invoice_id in number,
        p_start_date in date,
        p_end_date   in date,
        p_plan_code  in number
    );/*Ticket#7391*/

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

    procedure insert_invoice_line (
        p_invoice_id          in number,
        p_invoice_line_type   in varchar2 default 'INVOICE_LINE',
        p_rate_code           in varchar2,
        p_description         in varchar2,
        p_quantity            in number,
        p_no_of_months        in number,
        p_rate_cost           in number,
        p_total_cost          in number default null,
        p_batch_number        in number,
        x_invoice_line_id     out number,
        p_rate_plan_detail_id in number default null
    );

    procedure approve_invoice (
        p_invoice_id in number,
        p_user_id    in number
    );

/*
procedure proc_runout_credit_dist(p_emplr_id    in number
                            ,p_invoice_id           in number
                            ,p_start_date           in date
                            ,p_end_date             in date
                            ,P_LAST_INVOICE_DATE    in date
                            ,x_error_status         out varchar2
                            ,x_error_message        out varchar2
                            );
 */
    procedure proc_distribution_summary (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
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
        p_invoice_reason     in varchar2,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    );

    procedure post_ach_invoice (
        p_transaction_id in number
    );

    procedure post_invoice (
        p_transaction_id in number
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

    procedure post_check_invoice (
        p_invoice_id     in number,
        p_check_number   in varchar2,
        p_check_amount   in number,
        p_payment_method in varchar2,
        p_check_date     in date,
        p_user_id        in number
    );

    function get_actual_balance (
        p_acc_id     in number,
        p_plan_type  in varchar2,
        p_start_date in date,
        p_fee_date   in date
    ) return number;

    function get_minimum_inv_amount (
        p_entrp_id     in number,
        p_plan_type    in varchar2,
        p_rate_plan_id in number default null
    ) return number;

    procedure void_invoice (
        p_invoice_id  in number,
        p_user_id     in number,
        p_note        in varchar2 default null,
        p_status      in varchar2 default null,
        p_void_reason in varchar2
    ); -- Added By Jaggi ##9377
  /** 11/17/2016: Vanitha - Added per the request from Shavee to record void at line level **/

    procedure void_invoice_line (
        p_invoice_line_id in number,
        p_user_id         in number,
        p_note            in varchar2 default null,
        p_status          in varchar2 default null,
        p_void_reason     in varchar2 default null
    ); -- Added By Jaggi ##9377

    procedure update_invoice_amount (
        p_invoice_id in number,
        p_user_id    in number
    );

    procedure generate_monthly_invoice;

    procedure post_invoices (
        p_invoice_id     in number,
        p_check_number   in varchar2,
        p_check_amount   in number,
        p_payment_method in varchar2,
        p_check_date     in date,
        p_user_id        in number,
        p_paid_by        in varchar2
    ); -- added by Joshi 8692.

    procedure post_funding (
        p_invoice_id     in number,
        p_plan_type      in varchar2,
        p_reason_code    in number,
        p_check_number   in varchar2,
        p_check_amount   in number,
        p_payment_amount in number,
        p_user_id        in number,
        p_payment_method in number,
        p_entrp_id       in number,
        p_check_date     in date,
        p_start_date     in date,
        p_end_date       in date
    );

    procedure post_fees (
        p_invoice_id     in number,
        p_plan_type      in varchar2,
        p_reason_code    in number,
        p_check_number   in varchar2,
        p_check_amount   in number,
        p_payment_amount in number,
        p_user_id        in number,
        p_payment_method in number,
        p_entrp_id       in number,
        p_check_date     in date,
        p_start_date     in date,
        p_end_date       in date,
        p_paid_by        in varchar2 -- added by Joshi for 8692
    );

-- Claim Invoices
    procedure generate_claim_invoice (
        p_start_date    in date,
        p_end_date      in date,
        p_billing_date  in date default sysdate,
        p_entrp_id      in number,
        p_product_type  in varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2,
        p_division_code in varchar2 default null
    );

    procedure process_claim_invoice (
        p_start_date    in date,
        p_end_date      in date,
        p_invoice_id    in number,
        p_batch_number  in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

    procedure insert_ar_invoice (
        p_start_date     in date,
        p_end_date       in date,
        p_billing_date   in date default sysdate,
        p_entrp_id       in number,
        p_product_type   in varchar2,
        p_batch_number   in number,
        p_invoice_reason in varchar2 default 'CLAIM',
        x_invoice_id     out number,
        p_division_code  in varchar2 default null
    );

    procedure proc_claim_summary (
        p_invoice_id    in number,
        p_entrp_id      in number,
        p_start_date    in date,
        p_end_date      in date,
        p_product_type  in varchar2,
        p_division_code in varchar2 default null
    );

    procedure run_claim_invoice;

    function get_claim_invoice (
        p_invoice_id in number
    ) return pc_reports_pkg.claim_t
        pipelined
        deterministic;

    procedure save_claim_summary (
        p_invoice_id      in number,
        p_invoice_line_id in number,
        p_reason_code     in number,
        p_claim_id        in number,
        p_amount          in number,
        p_division_code   in varchar2 default null,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    );

    procedure delete_claim_summary (
        p_invoice_id      in number,
        p_invoice_line_id in number,
        p_claim_id        in number
    );

    procedure update_ar_inv_lines (
        p_invoice_line_id in number
    );

    procedure create_invoice (
        p_start_date     in date,
        p_end_date       in date,
        p_billing_date   in date default sysdate,
        p_entrp_id       in number,
        p_product_type   in varchar2,
        p_invoice_reason in varchar2,
        x_invoice_id     out number,
        x_error_status   out varchar2,
        x_error_message  out varchar2,
        p_division_code  in varchar2 default null
    );

    procedure process_funding_invoice (
        p_start_date    in date,
        p_end_date      in date,
        p_invoice_id    in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

    procedure generate_funding_invoice (
        p_start_date     in date,
        p_end_date       in date,
        p_billing_date   in date default sysdate,
        p_entrp_id       in number,
        p_product_type   in varchar2,
        p_invoice_reason in varchar2,
        x_invoice_id     out number,
        x_error_status   out varchar2,
        x_error_message  out varchar2,
        p_division_code  in varchar2 default null
    );

    procedure process_payroll_invoice (
        p_start_date    in date,
        p_end_date      in date,
        p_invoice_id    in number,
        p_batch_number  in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

    procedure generate_payroll_invoice (
        p_start_date     in date,
        p_end_date       in date,
        p_billing_date   in date default sysdate,
        p_entrp_id       in number,
        p_product_type   in varchar2,
        p_invoice_reason in varchar2,
        x_invoice_id     out number,
        x_error_status   out varchar2,
        x_error_message  out varchar2,
        p_division_code  in varchar2 default null
    );

    procedure proc_funding_summary (
        p_invoice_id    in number,
        p_entrp_id      in number,
        p_start_date    in date,
        p_end_date      in date,
        p_product_type  in varchar2,
        p_division_code in varchar2 default null
    );

    function get_funding_invoice (
        p_invoice_id in number
    ) return pc_reports_pkg.claim_t
        pipelined
        deterministic;

    function get_fee (
        p_invoice_id  in number,
        p_reason_code in number,
        p_start_date  in date,
        p_end_date    in date
    ) return number;

    function get_outstanding_balance (
        p_entity_id      in number,
        p_entity_type    in varchar2,
        p_invoice_reason in varchar2,
        p_invoice_id     in number
    ) return number;

    procedure run_payroll_invoice (
        p_payroll_date in date,
        p_entrp_id     in number default null
    );

    function getinvoice (
        p_invoice_id in number
    ) return ret_get_invoice_t
        pipelined
        deterministic;

    procedure post_refund (
        p_invoice_id    in number,
        p_pay_code      in number,
        p_check_amount  in number,
        p_issue_check   in varchar2,
        p_reason_code   in number,
        p_note          in varchar2,
        p_refund_date   in date,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure retry_ach (
        p_invoice_id in number,
        p_user_id    in number
    );

    function get_tax (
        p_rate_plan_id in number
    ) return number;

    procedure apply_tax (
        p_batch_number in number
    );

  -- 03/11/2017:Vanitha:Invoice notification enhancement

    procedure insert_inv_notif (
        p_invoice_id      in number,
        p_invoice_age     in number,
        p_notif_type      in varchar2,
        p_email           in varchar2,
        p_notification_id in number,
        p_template_name   in varchar2
    );

    procedure update_result_sent (
        p_invoice_notify_id in number,
        p_notification_id   in number
    );

-- 6322: Added by Joshi for paying invoice online.
    procedure pay_invoice_online (
        p_invoice_id       number,
        p_entrp_id         in number,
        p_entity_id        in number    -- Added by Joshi for 9142
        ,
        p_entity_type      in varchar2  -- Added by Joshi for 9142
        ,
        p_bank_acct_id     in number,
        p_bank_acct_type   in varchar2,
        p_bank_routing_num in varchar2,
        p_bank_acct_num    in varchar2,
        p_bank_name        in varchar2,
        p_auto_pay         in varchar2,
        p_account_usage    in varchar2,
        p_division_code    in varchar2,
        p_user_id          in number,
        p_business_name    in varchar2  -- Added by Swamy for Ticket#12534
        ,
        x_bank_acct_id     out number   -- Added by Swamy for Ticket#12309
        ,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    );

    procedure generate_hsa_monthly_invoice;

  -- Start Added by swamy for sql injection (White hat www Vid: 48289429)
    type invoice_rec is record (
            reason_name       varchar2(255),
            description       varchar2(2000),
            quantity          number,
            unit_rate_cost    number,
            total_line_amount number,
            no_of_months      number,
            pers_name         varchar2(2000),
            enrolled_date     varchar2(30),
            effective_date    varchar2(30),
            rate_code         varchar2(30),
            calculation_type  varchar2(30)
    );
    type ar_invoice_row_t is record (
            rownum_1            number,
            invoice_number      varchar2(30),
            invoice_date        varchar2(30),
            invoice_due_date    varchar2(30),
            status_code         varchar2(255),
            status              varchar2(11),
            invoice_posted_date varchar2(30),
            invoice_id          number,
            entrp_id            number,
            acc_id              number,
            acc_num             varchar2(30),
            invoice_term        varchar2(4000),
            start_date          varchar2(30),
            end_date            varchar2(30),
            coverage_period     varchar2(21),
            comments            varchar2(3200),
            auto_pay            varchar2(30),
            billing_name        varchar2(255),
            billing_address     varchar2(255),
            billing_city        varchar2(255),
            billing_zip         varchar2(255),
            billing_state       varchar2(255),
            billing_attn        varchar2(255),
            payment_method      varchar2(255),
            invoice_status      varchar2(255),
            invoice_reason      varchar2(100),
            division_code       varchar2(255),
            refund_amount       number            -- Added by Jaggi ##9980
            ,
            invoice_amount      number,
            pending_amount      number,
            paid_amount         number,
            void_amount         number,
            entity_id           number,
            entity_type         varchar2(30),
            division_name       varchar2(255),
            plan_type           varchar2(255),
            employer_name       varchar2(4000),
            account_type        varchar2(4000),
            created_by          varchar2(4000)    -- Added by Jaggi ##9793
            ,
            enrolle_type        varchar2(255)     -- Added by Jaggi ##9793
    );
    type paymentreceived_rec is record (
            check_date   employer_payments.check_date%type,
            check_number employer_payments.check_number%type,
            check_amount employer_payments.check_amount%type,
            reason_name  fee_names.fee_name%type,
            plan_type    employer_payments.plan_type%type,
            note         employer_payments.note%type
    );
    type invoice_line_rec is record (
            reason_name       varchar2(255),
            description       varchar2(2000),
            quantity          number,
            unit_rate_cost    number,
            total_line_amount number,
            no_of_months      number,
            pers_name         varchar2(2000),
            enrolled_date     varchar2(30),
            effective_date    varchar2(30),
            rate_code         varchar2(30)
    );
    type ar_invoice_t is
        table of ar_invoice_row_t;
    type invoice_tbl is
        table of invoice_rec;
    type invoice_line_tbl is
        table of invoice_line_rec;
    type payreceived_tbl is
        table of paymentreceived_rec;
    type l_cursor is ref cursor;
    function get_active_invdetail (
        p_invoice_id in number
    ) return invoice_tbl
        pipelined
        deterministic;

    function get_runout_invdetail (
        p_invoice_id in number
    ) return invoice_tbl
        pipelined
        deterministic;

    function get_adj_invdetail (
        p_invoice_id in number
    ) return invoice_tbl
        pipelined
        deterministic;

    function get_claim_invdetail (
        p_invoice_id in number
    ) return invoice_tbl
        pipelined
        deterministic;

    function get_payment_received (
        p_invoice_id in number
    ) return payreceived_tbl
        pipelined
        deterministic;

    function get_invoice_info (
        p_invoice_num    in number,
        p_status_code    in varchar2,
        p_division_code  in varchar2,
        p_invoice_reason in varchar2,
        p_acc_num        in varchar2,
        p_from_date      in varchar2,
        p_to_date        in varchar2,
        p_flag           in varchar2,
        p_start_row      in number,
        p_end_row        in number,
        p_sort_column    in varchar2,
        p_sort_order     in varchar2
    ) return ar_invoice_t
        pipelined
        deterministic;

    function get_invoice_tax (
        p_invoice_id in number
    ) return invoice_line_tbl
        pipelined
        deterministic;
  -- End Of Addition By Swamy For Sql Injection

   -- Vantha : Service charge changes
    procedure insert_rate_plan_detail (
        p_rate_plan_id       in number,
        p_calculation_type   in varchar2,
        p_minimum_range      in number,
        p_maximum_range      in number,
        p_description        in varchar2,
        p_rate_code          in varchar2,
        p_rate_plan_cost     in number,
        p_rate_basis         in varchar2,
        p_effective_date     in date,
        p_effective_end_date in date,
        p_one_time_flag      in varchar2,
        p_invoice_param_id   in number,
        p_user_id            in number,
        p_charged_to         in varchar2    -- added by swamy for ticket#11119
    );

    procedure apply_service_charge (
        p_batch_number in number
    );
  -- Vantha : Service charge changes

-- Added by Swamy for Ticket#8037
    procedure hsa_auto_invoice_approval;

-- Added by Joshi for 8741. to generate fee invoice for COBRA setup/renewal(monthly fee collection).
    procedure generate_monthly_fee_comp (
        p_start_date    in date,
        p_end_date      in date,
        p_billing_date  in date default sysdate,
        p_entrp_id      in number,
        p_account_type  in varchar2 default null,
        x_error_status  out varchar2,
        x_error_message out varchar2,
        p_invoice_type  in varchar2 default null,
        p_division_code in varchar2 default null,
        x_batch_number  out number
    );

    procedure apply_minimum_fee (
        p_invoice_id in number
    );

-- Added by Jaggi for 9142
    function get_inv_info_for_broker (
        p_entity_id    in number,
        p_entity_type  in varchar2,
        p_status_code  in varchar2,
        p_acc_num      in varchar2,
        p_product_type in varchar2,
        p_from_date    in varchar2,
        p_to_date      in varchar2,
        p_flag         in varchar2,
        p_start_row    in number,
        p_end_row      in number,
        p_sort_column  in varchar2,
        p_sort_order   in varchar2
    ) return ar_invoice_t
        pipelined
        deterministic;

-- Added by Joshi for 9890.
    procedure export_invoice_upload_file (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    );

    procedure validate_invoice_upload_data (
        p_batch_number in number,
        p_user_id      in number
    );

    procedure process_invoice_upload_file (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    );

    procedure process_invoices (
        p_batch_number  in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

/** Vanitha:for cobra project ***/
    procedure insert_rate_detail (
        p_invoice_upload_tab invoice_upload_rec,
        x_error_status       out varchar2,
        x_error_message      out varchar2
    );

    procedure insert_premium_invoice (
        p_start_date     in date,
        p_end_date       in date,
        p_billing_date   in date default sysdate,
        p_due_date       in date default sysdate,
        p_pers_id        in number,
        p_product_type   in varchar2 default 'COBRA',
        p_batch_number   in number,
        p_invoice_reason in varchar2 default 'PREMIUM',
        x_invoice_id     out number,
        p_division_code  in varchar2 default null
    );

    procedure process_cobra_premium (
        p_start_date    in date,
        p_end_date      in date,
        p_billing_date  in date default sysdate,
        p_due_date      in date default sysdate,
        p_product_type  in varchar2,
        p_pers_id       in number,
        p_batch_number  in number,
        x_invoice_id    out number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

    function is_autopay_scheduled (
        p_entty_id    in number,
        p_entity_type in varchar2
    ) return varchar2;

    procedure post_premium (
        p_transaction_id in number,
        p_invoice_id     in number
    );

    procedure post_cc_for_premium (
        p_batch_number in number
    );
-- Vanitha

-- Added by Joshi for 10742
    procedure generate_amendment_fee_invoice (
        p_acc_id number
    );

-- Added by Joshi for 10847
    function get_product_type (
        p_invoice_id number
    ) return varchar2;

--Added by Joshi for GA consolidated stmt(11061)
    function get_invoice_frequency (
        p_invoice_id number
    ) return varchar2;

-- Added by Jaggi 11129
    procedure updateinv_pay_method (
        p_invoice_id    in number,
        p_user_id       in number,
        p_account_usage in varchar2,
        p_division_code in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

-- Added by Joshi for Generating invoice for Online enrollment and renewals.(#11119)
    procedure generate_daily_setup_renewal_invoice (
        p_entrp_id in number default null
    );

--  Added by Swamy #11119
    procedure insert_daily_enroll_renewal_account_info (
        p_batch_number in number,
        p_entrp_id     in number default null,
        p_source       in varchar2
    );

 --  Added by swamy for  #11119
 --  Added by swamy for  #11119
    procedure insert_discount_rate_lines (
        p_batch_number     in number,
        p_entrp_id         in number,
        p_quote_header_id  in number,
        p_rate_plan_id     in number,
        p_invoice_param_id in number,
        p_source           in varchar2,
        p_fee              in number
    );
 --  Added by Jaggi for  #11119
    procedure insert_inv_parameters (
        p_entrp_id         in number,
        p_payment_method   in varchar2,
        p_bank_acct_id     in number,
        p_payment_term     in varchar2,
        p_inv_frequency    in varchar2,
        p_rate_plan_id     in number,
        p_invoice_type     in varchar2,
        p_product_type     in varchar2,
        p_user_id          in number,
        p_billing_name     in varchar2,
        p_billing_attn     in varchar2,
        p_billing_address  in varchar2,
        p_billing_city     in varchar2,
        p_billing_zip      in varchar2,
        p_billing_state    in varchar2,
        x_invoice_param_id out number
    );

 --  Added by Jaggi for  #11119
    procedure setup_inv_parameter_for_employer (
        p_entrp_id       in number,
        p_batch_number   in number,
        p_payment_method in varchar2,
        p_bank_acct_id   in number,
        p_inv_frequency  in varchar2,
        p_rate_plan_id   in number
    );

    procedure generate_daily_renewal_invoice (
        p_batch_number in number,
        p_entrp_id     in number default null
    );

    procedure generate_daily_setup_invoice (
        p_batch_number in number,
        p_entrp_id     in number default null
    );

    procedure insert_fsa_hra_monthly_rate_lines (
        p_entrp_id         in number,
        p_rate_plan_id     in number,
        p_invoice_param_id in number,
        p_source           in varchar2,
        p_batch_number     in number
    );

    procedure get_description (
        p_account_type    in varchar2,
        p_acc_id          in number,
        p_source          in varchar2,
        p_ben_plan_id     in number,
        p_ben_plan_number in varchar2,
        p_plan_type       out varchar2
    );

    function get_pppm_discount (
        p_acc_id in number,
        p_source in varchar2
    ) return number;
-- Added by Joshi for showing charged_to in the SAM approve invoice sceen(#11366)
    function get_charged_to (
        p_invoice_id in number
    ) return varchar2;

-- Added by Jaggi #11294
    procedure populate_monthly_inv_payment_dtl (
        p_entrp_id        in number,
        p_source          in varchar2,
        p_payment_method  in varchar2,
        p_bank_acct_id    in varchar2,
        p_charged_to      in varchar2,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_user_id         number
    );    -- Added by Joshi for 12091

    procedure post_cc_refund (
        p_invoice_id    in number,
        p_refund_amount in number,
        p_note          in varchar2,
        p_user_id       in number,
        x_error_message out varchar2,
        x_error_status  out varchar2
    );

-- Added by Joshi for #11801
    function is_monthly_invoice (
        p_invoice_id in number
    ) return varchar2;     

-- Added by Joshi for 11998.
    function get_cobra_monthly_admin_fee return number;

-- Added by Joshi for 12255 
    function get_invoice_cc_detail (
        p_invoice_id number
    ) return invoice_creditcard_info_t
        pipelined
        deterministic;

    procedure post_cc_fee_invoice (
        p_batch_number  number,
        p_invoice_id    number,
        p_user_id       number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

    function get_cc_payment_detail (
        p_invoice_id in number
    ) return sys_refcursor;

    function get_original_invoice_id (
        p_cc_fee_invoice_id number
    ) return number;

    procedure giac_pay_invoice_online (
        p_invoice_id          in number,
        p_entrp_id            in number,
        p_entity_id           in number,
        p_entity_type         in varchar2,
        p_bank_acct_id        in number,
        p_bank_acct_type      in varchar2,
        p_bank_routing_num    in varchar2,
        p_bank_acct_num       in varchar2,
        p_bank_name           in varchar2,
        p_auto_pay            in varchar2,
        p_account_usage       in varchar2,
        p_division_code       in varchar2,
        p_user_id             in number,
        p_bank_status         in varchar2,
        p_giact_verify        in varchar2,
        p_gverify             in varchar2,
        p_gauthenticate       in varchar2,
        p_gresponse           in varchar2,
        p_business_name       in varchar2,
        x_bank_acct_id        out number,
        x_giact_return_status out varchar2,
        x_giact_error_message out varchar2,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    );

    procedure giact_pay_invoice_online (
        p_entity_id     in number,
        p_entity_type   in varchar2,
        p_invoice_id    in number,
        p_entrp_id      in number,
        p_auto_pay      in varchar2,
        p_division_code in varchar2,
        p_user_id       in number,
        p_bank_acct_id  in number,
        p_account_usage in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

end pc_invoice;
/

