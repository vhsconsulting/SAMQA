create or replace package samqa.pc_commission as
    type enrolled_row is record (
            er_acc_num      varchar2(30),
            entrp_id        number,
            broker_id       number,
            salesrep_id     number,
            no_of_accounts  number,
            acc_num         varchar2(30),
            acc_id          number,
            renewal         varchar2(30),
            fee_paid_date   date,
            setup_paid_date date,
            rew_paid_date   date,
            plan_start_date date,
            plan_end_date   date,
            renewal_date    date,
            product_type    varchar2(30),
            employer_name   varchar2(255),
            fee_amount      number,
            effective_date  varchar2(30),
            plan_doc_flag   varchar2(1),
            invoice_id      number
    );
    type sales_rep_comm_row is record (
            salesrep_id        number,
            processed_date     date,
            period_start_date  date,
            period_end_date    date,
            revenue_per_acct   number,
            comm_amt_perc      number,
            transaction_amount number,
            quantity           number,
            account_category   varchar2(30),
            account_type       varchar2(30),
            effective_date     varchar2(30),
            entrp_id           number,
            plan_doc_flag      varchar2(1)
    );
    type broker_comm_row is record (
            pers_id          number,
            entrp_id         number,
            person_name      varchar2(2000),
            entrp_name       varchar2(2000),
            fees             number,
            commission       number,
            no_of_employees  number,
            account_category varchar2(2000),
            broker_rate      number,
            broker_id        number,
            broker_lic       varchar2(255)
    );
    type account_type_row is record (
            account_type varchar2(255),
            meaning      varchar2(255)
    );
    type sales_rep_row is record (
            rep_name    varchar2(255),
            salesrep_id number,
            manager_id  number,
            email       varchar2(255)
    );

   -- Added by Joshi for 5022-salescommission
    type salerep_comm_det_row is record (
            employer_name varchar2(255),
            acc_num       varchar2(30),
            account_type  varchar2(255),
            comm_flag     varchar2(20),
            rep_name      varchar2(255),
            fee_paid      number,
            saved_date    date
    );
    type salerep_comm_det_t is
        table of salerep_comm_det_row;
    type broker_comm_t is
        table of broker_comm_row;
    type account_type_t is
        table of account_type_row;
    type enrolled_row_t is
        table of enrolled_row;
    type sales_rep_row_t is
        table of sales_rep_row;
    type sales_rep_comm_row_t is
        table of sales_rep_comm_row;
    procedure archive_sales_commission (
        p_start_date in varchar2,
        p_end_date   in varchar2,
        p_user_id    in varchar2
    );

    procedure archive_pop_commission (
        p_user_id  in varchar2,
        p_entrp_id in number
    );

    procedure archive_hra_fsa_commission (
        p_start_date in varchar2,
        p_end_date   in varchar2,
        p_entrp_id   in number,
        p_user_id    in number
    );

    function get_total_account (
        p_account_type in varchar2,
        p_start_date   in date,
        p_end_date     in date,
        p_reason_code  in number
    ) return number;

    function get_revenue_per_account (
        p_account_type in varchar2,
        p_start_date   in date,
        p_end_date     in date,
        p_reason_code  in number
    ) return number;

    function get_ytd_revenue (
        p_account_type in varchar2,
        p_end_date     in date,
        p_reason_code  in number
    ) return number;

    function get_sales_revenue (
        p_account_type in varchar2,
        p_start_date   in date,
        p_end_date     in date,
        p_reason_code  in number,
        p_entrp_id     in number
    ) return number;

    function get_revenue (
        p_account_type in varchar2,
        p_start_date   in date,
        p_end_date     in date,
        p_reason_code  in number
    ) return number;

    function calculate_commission (
        p_account_type in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return sales_rep_comm_row_t
        pipelined
        deterministic;

    function get_all_commissions (
        p_start_date in date,
        p_end_date   in date
    ) return sales_rep_comm_row_t
        pipelined
        deterministic;

    function get_summary_enrolled_report (
        p_account_type in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return enrolled_row_t
        pipelined
        deterministic;

    function get_summary_salesrep_report (
        p_account_type in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return enrolled_row_t
        pipelined
        deterministic;

    function get_commission_amount (
        p_account_type in varchar2,
        p_renewal_flag in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return number;

    procedure save_comm_payment (
        p_account_type in varchar2,
        p_start_date   in date,
        p_end_date     in date,
        p_user_id      in number
    );

    procedure save_commissions (
        p_account_type in varchar2 default null,
        p_start_date   in date,
        p_end_date     in date,
        p_user_id      in number
    );

    function get_commission (
        p_account_type in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return varchar2;

    function get_payment_count (
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    ) return number;

    function get_sales_rep_tree (
        p_user_id in number
    ) return sales_rep_row_t
        pipelined
        deterministic;

    function get_sales_rep_email (
        p_salesrep_id in number
    ) return varchar2;

    function is_plan_doc_only (
        p_entrp_id     in number,
        p_product_type in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return varchar2;

    procedure calc_hrafsa_broker_comm (
        p_start_date in date,
        p_end_date   in date,
        p_user_id    in number
    );

    function get_broker_commission (
        p_account_type in varchar2,
        p_broker_id    in number,
        p_start_date   in varchar2,
        p_end_date     in varchar2
    ) return broker_comm_t
        pipelined
        deterministic;

    function get_account_type (
        p_broker_id in number
    ) return account_type_t
        pipelined
        deterministic;

    procedure auto_save_commission;

    procedure sales_new_revenue_report;

    procedure sales_renewal_revenue_report;

    procedure sales_company_revenue_report;

    procedure run_broker_commission;
      /*Ticket#5022 */
    function calculate_new_commission (
        p_account_type in varchar2 default null,
        p_start_date   in date,
        p_end_date     in date
    ) return sales_rep_comm_row_t
        pipelined
        deterministic;

    procedure save_comm_payment_new (
        p_start_date in date,
        p_end_date   in date,
        p_user_id    in number
    );
  -- FUNCTION GET_SUMM_SALES_REPORT_NEW (P_ACCOUNT_TYPE IN VARCHAR2,P_START_DATE IN DATE,P_END_DATE IN DATE)
   --  RETURN  enrolled_row_t PIPELINED DETERMINISTIC ;
    procedure insert_sales_comm_data (
        p_start_date in date,
        p_end_date   in date,
        p_user_id    in number
    );

    function get_summ_salesrep_report_old (
        p_account_type in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return enrolled_row_t
        pipelined
        deterministic;

    function get_salesrep_comm_detail (
        p_account_type in varchar2,
        p_salesrep_id  number,
        p_start_date   in date,
        p_end_date     in date
    ) return salerep_comm_det_t
        pipelined
        deterministic;
    /*Ticket#5022 */

   /* Procedure created by Swamy for Ticket#7766  */
    procedure insert_sales_commission_report (
        p_start_date date default null,
        p_end_date   date default null
    );
   -- 7922 Joshi
    procedure monthly_new_revenue_report (
        p_start_date date default null,
        p_end_date   date default null
    );
   -- SK 05_12_2020
    procedure monthly_renewal_revenue_report (
        p_start_date date default null,
        p_end_date   date default null
    );
   -- SK 05_12_2020
    procedure new_hsa_commission_report (
        p_start_date date default null,
        p_end_date   date default null
    );--SK ADDED ON 06/03/2021
    procedure generate_sales_summary_report (
        p_start_date date default null,
        p_end_date   date default null
    );

    procedure monthly_new_rev_summary_report (
        p_start_date date default null,
        p_end_date   date default null
    );

    procedure monthly_company_rev_report (
        p_start_date date default null,
        p_end_date   date default null
    );

    procedure monthly_cpy_rev_summary_report (
        p_start_date date default null,
        p_end_date   date default null
    );

    procedure monthly_rwl_rev_summary_report (
        p_start_date date default null,
        p_end_date   date default null
    );

end pc_commission;
/


-- sqlcl_snapshot {"hash":"1a8bc3501850919c9102a26fbfe1435e5ff2ac6e","type":"PACKAGE_SPEC","name":"PC_COMMISSION","schemaName":"SAMQA","sxml":""}