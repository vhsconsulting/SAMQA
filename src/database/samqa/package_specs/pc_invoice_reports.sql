create or replace package samqa.pc_invoice_reports is
    type invoice_rec is record (
            invoice_number     varchar2(100),
            invoice_date       varchar2(30),
            invoice_term       varchar2(255),
            coverage_period    varchar2(255),
            invoice_due_date   varchar2(30),
            invoice_amount     number,
            comments           varchar2(2000),
            invoice_id         number,
            auto_pay           varchar2(30),
            payment_method     varchar2(100),
            billing_name       varchar2(2000),
            billing_attn       varchar2(2000),
            billing_address    varchar2(2000),
            billing_city       varchar2(255),
            billing_zip        varchar2(30),
            billing_state      varchar2(30),
            start_date         date,
            end_date           date,
            no_of_months       number,
            detailed_reporting varchar2(30),
            pending_amount     number,
            min_inv_amount     number,
            min_hra_inv_amount number,
            invoice_status     varchar2(100),
            employer_name      varchar2(2000),
            paid_amount        number,
            bal_due            number,
            total_due          number,
            current_balance    number,
            pop_comp           varchar2(100),
            acc_num            varchar2(100),
            division_name      varchar2(1000),
            division_code      varchar2(100),
            entrp_id           number
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
            rate_code         varchar2(30),
            invoice_line_type varchar2(255),
            calculation_type  varchar2(255)
    );
    type revenue_report_rec is record (
            invoice_number    varchar2(100),
            invoice_id        number,
            employer_name     varchar2(255),
            start_date        varchar2(100),
            end_date          varchar2(100),
            invoice_date      varchar2(100),
            invoice_due_date  varchar2(100),
            invoice_amount    varchar2(100),
            paid_amount       varchar2(100),
            pending_amount    varchar2(100),
            refund_amount     varchar2(100),
            invoice_term      varchar2(255),
            payment_method    varchar2(100),
            billing_name      varchar2(255),
            billing_attn      varchar2(255),
            billing_address   varchar2(1000),
            account_type      varchar2(255),
            reason_name       varchar2(255),
            total_line_amount varchar2(100),
            void_amount       varchar2(100),
            effective_date    varchar2(255),
            status            varchar2(255),
            sales_rep         varchar2(255),
            css               varchar2(255),
            stacked           varchar2(255),
            invoice_line_type varchar2(255)
    );
    type unpaid_invoice_rec is record (
            invoice_number        varchar2(100),
            invoice_id            number,
            employer_name         varchar2(2000),
            invoice_date          varchar2(30),
            billing_date          varchar2(30),
            invoice_due_date      varchar2(30),
            invoice_posted_date   varchar2(30),
            cancelled_date        varchar2(30),
            invoice_type          varchar2(30),
            invoice_amount        varchar2(30),
            paid_amount           varchar2(30),
            pending_amount        varchar2(30),
            void_amount           varchar2(30),
            entity_id             number,
            entity_type           varchar2(30),
            invoice_term          varchar2(255),
            payment_method        varchar2(255),
            batch_number          varchar2(255),
            comments              varchar2(3200),
            auto_pay              varchar2(30),
            acc_num               varchar2(30),
            status                varchar2(255),
            invoice_reason        varchar2(100),
            age_of_invoice        number,
            billing_name          varchar2(255),
            billing_attn          varchar2(255),
            billing_address       varchar2(3200),
            no_employees          number,
            ctsy_notice1_sent_on  varchar2(30),
            ctsy_notice2_sent_on  varchar2(30),
            final_notice_sent_on  varchar2(30),
            urgent_notice_sent_on varchar2(30) -- Added by jaggi #11699
            ,
            emailed_to            varchar2(1000),
            sent_to_collection_on varchar2(30),
            collection_sent_on    varchar2(30),
            division_code         varchar2(100),
            broker_name           varchar2(2000)
    );

-- Added by Jaggi for 9830.
    type ga_monthly_stmt_row_rec is record (
            client_name       varchar2(100),
            client_id         varchar2(20),
            invoice_id        number,
            invoice_date      varchar2(30),
            start_date        varchar2(30),
            end_date          varchar2(30),
            description       varchar2(3200),
            quantity          number,
            no_of_months      number,
            unit_rate_cost    number,
            total_line_amount number
    );
    type ga_monthly_stmt_t is
        table of ga_monthly_stmt_row_rec;
    type unpaid_invoice_tbl is
        table of unpaid_invoice_rec;
    type invoice_tbl is
        table of invoice_rec;
    type invoice_line_tbl is
        table of invoice_line_rec;
    type revenue_report_tbl is
        table of revenue_report_rec;

-- Added by Joshi for 10746

    type erisacobrapopfeeinvoicenotify_rec is record (
            invoice_id number,
            acc_num    varchar2(30)
    );
    type erisacobrapopfeeinvoicenotify_t is
        table of erisacobrapopfeeinvoicenotify_rec;
    function get_invoice (
        p_invoice_id   in number,
        p_invoice_type in varchar2
    ) return invoice_tbl
        pipelined
        deterministic;

    function get_invoice_lines (
        p_invoice_id        in number,
        p_invoice_line_type in varchar2,
        p_source            in varchar2,
        p_product_type      in varchar2
    ) return invoice_line_tbl
        pipelined
        deterministic;

    function get_tax (
        p_invoice_id in number
    ) return invoice_line_tbl
        pipelined
        deterministic;

   -- 03/11/2017:Vanitha:Invoice notification enhancement

    procedure send_inv_remind_notif;

    function get_invoice_notify return pc_notifications.notification_t
        pipelined
        deterministic;

    procedure monthly_ar_report (
        p_report_type in varchar2,
        p_start_date  in date,
        p_end_date    in date
    );

    procedure monthly_revenue_report (
        p_start_date   in date,
        p_end_date     in date,
        p_account_type in varchar2,
        p_report_type  in varchar2
    );

    procedure schedule_invoice_report;

    function get_unpaid_invoices (
        p_entrp_id     number default null,
        p_account_type varchar2 default null,
        p_acc_num      varchar2 default null,
        p_invoice_id   number default null,
        p_invoice_type varchar2 default null,
        p_invoice_date varchar2 default null,
        p_inv_date_to  varchar2 default null
    ) return unpaid_invoice_tbl
        pipelined
        deterministic;

    function get_erisacobrapop_lines (
        p_invoice_id        in number,
        p_invoice_line_type in varchar2,
        p_source            in varchar2,
        p_product_type      in varchar2
    ) return invoice_line_tbl
        pipelined
        deterministic;

    function get_funding_invoice_lines (
        p_invoice_id        in number,
        p_invoice_line_type in varchar2,
        p_source            in varchar2,
        p_product_type      in varchar2
    ) return invoice_line_tbl
        pipelined
        deterministic;

    function get_claim_invoice_lines (
        p_invoice_id        in number,
        p_invoice_line_type in varchar2,
        p_source            in varchar2,
        p_product_type      in varchar2
    ) return invoice_line_tbl
        pipelined
        deterministic;

    function get_unpaid_invoices_v2 (
        p_entrp_id     number default null,
        p_account_type varchar2 default null,
        p_acc_num      varchar2 default null,
        p_invoice_id   number default null,
        p_invoice_type varchar2 default null,
        p_invoice_date varchar2 default null,
        p_inv_date_to  varchar2 default null
    ) return unpaid_invoice_tbl
        pipelined
        deterministic;

-- Added by Jaggi for 98300.
    function get_ga_monthly_stmt (
        p_ga_id        number,
        p_invoice_date varchar2 default null,
        p_inv_date_to  varchar2 default null,
        p_account_type varchar2 default null  -- Added by Joshi for 10744
    ) return ga_monthly_stmt_t
        pipelined
        deterministic;

-- Added by Joshi for 10744.
    function geterisacobrapopfeeinvoicenotify return erisacobrapopfeeinvoicenotify_t
        pipelined
        deterministic;

end pc_invoice_reports;
/


-- sqlcl_snapshot {"hash":"7e24f92c7f03c47432bf6e199c54f91b23c880df","type":"PACKAGE_SPEC","name":"PC_INVOICE_REPORTS","schemaName":"SAMQA","sxml":""}