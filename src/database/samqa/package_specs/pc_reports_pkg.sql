create or replace package samqa.pc_reports_pkg as
    type overview_row_t is record (
            open_mm       number,
            pending_mm    number,
            inv_mm        number,
            close_mm      number,
            open_total    number,
            pending_total number,
            inv_total     number,
            close_total   number,
            open_perc     number,
            pending_perc  number,
            inv_perc      number,
            close_perc    number
    );
    type overview_t is
        table of overview_row_t;
    type feature_row_t is record (
            card_count        number,
            card_new_count    number,
            ben_count         number,
            online_user_count number,
            email_user_count  number,
            card_perc         number,
            card_new_perc     number,
            ben_perc          number,
            online_user_perc  number,
            email_user_perc   number,
            total_account     number
    );
    type feature_t is
        table of feature_row_t;
    type balance_row_t is record (
            acc_balance        number,
            investment_balance number,
            total_balance      number
    );
    type balance_t is
        table of balance_row_t;
    type balance_range_row_t is record (
            description    varchar2(2000),
            no_of_accounts number,
            total_amount   number,
            perc_account   number
    );
    type balance_range_t is
        table of balance_range_row_t;
    type transaction_row_t is record (
            description  varchar2(2000),
            no_of_txns   number,
            total_amount number,
            avg_amount   number
    );
    type transaction_t is
        table of transaction_row_t;
    type spend_save_row_t is record (
            transaction_type varchar2(2000),
            description      varchar2(2000),
            no_of_txns       number,
            perc_of_txns     varchar2(255)
    );
    type spend_save_t is
        table of spend_save_row_t;
    type disb_detail_row_t is record (
            transaction_type    varchar2(2000),
            avg_no_of_txns      number,
            perc_of_txns        number,
            avg_amount          number,
            avg_amount_per_acct number,
            perc_amount         number
    );
    type disb_detail_t is
        table of disb_detail_row_t;
    type disb_breakdown_row_t is record (
            transaction_type varchar2(2000),
            perc_of_txns     number
    );
    type disb_breakdown_t is
        table of disb_breakdown_row_t;
    type plans_row_t is record (
            acc_id     number,
            plans      varchar2(30),
            start_date date,
            end_date   date
    );
    type plans_t is
        table of plans_row_t;
    type er_online_accounts_t is record (
            entrp_id   number,
            first_name varchar2(30),
            last_name  varchar2(30),
            acc_num    varchar2(30)
    );
    type ret_er_online_accounts_t is
        table of er_online_accounts_t;
    type all_deposits_row_t is record (
            acc_num          varchar2(30),
            check_date       varchar2(30),
            check_amount     number,
            check_number     varchar2(255),
            reason_code      varchar2(255),
            payment_method   varchar2(255),
            transaction_type varchar2(255),
            note             varchar2(3200),
            plan_name        varchar2(255)
    );
    type all_deposits_t is
        table of all_deposits_row_t;
    type dibursement_row is record (
            claim_amount    number,
            fee_date        date,
            next_fee_date   date,
            expiration_date date,
            rolled_over     varchar2(1)
    );
    type dibursement_t is
        table of dibursement_row;
    type expire_funds_row is record (
            acc_num         varchar2(255),
            expired_amount  number,
            expiration_date date
    );
    type expire_funds_t is
        table of expire_funds_row;
    type contribution_row is record (
            contribution_amount number,
            disbursed_amount    number,
            acc_id              number,
            plan_type           varchar2(255),
            account_type        varchar2(255),
            fee_date            date,
            next_fee_date       date,
            expiration_date     date,
            fee_reason          varchar2(255),
            rolled_over         varchar2(1),
            claim_amount        number,
            remaining_balance   number,
            expired_funds       number
    );
    type contribution_t is
        table of contribution_row;
    type plan_info_row is record (
            ben_plan_id       number,
            plan_type         varchar2(30),
            plan_type_meaning varchar2(255),
            plan_start_date   date,
            plan_end_date     date
    );
    type plan_info_t is
        table of plan_info_row;
    type claim_row is record (
            acc_num              varchar2(30),
            first_name           varchar2(255),
            last_name            varchar2(255),
            pay_date             varchar2(30),
            claim_amount         number,
            deductible_amount    number,
            approved_amount      number,
            claim_pending        number,
            denied_amount        number,
            check_amount         number,
            check_number         varchar2(30),
            transaction_number   varchar2(30),
            reimbursement_method varchar2(255),
            division_code        varchar2(255),
            division_name        varchar2(255),
            reason_code          varchar2(30),
            service_type         varchar2(30),
            service_type_meaning varchar2(255),
            plan_start_date      date,
            plan_end_date        date,
            provider_name        varchar2(255),
            plan_year            varchar2(255),
            claim_date           varchar2(30),
            name                 varchar2(255),
            remaining_offset_amt number,
            substantiated_flag   varchar2(30),
            claim_status         varchar2(30),
            pers_id              number,
            acc_id               number,
            claim_id             number,
            claim_code           varchar2(50),
            request_date         varchar2(10),
            claim_type           varchar2(255),
            claim_stat_meaning   varchar2(4000),
            claim_source         varchar2(9),
            claim_category       varchar2(255),
            vendor_id            number,
            bank_acct_id         number
    );
    type claim_t is
        table of claim_row;
    type member_row is record (
            ssn                 varchar2(30),
            first_name          varchar2(255),
            middle_name         varchar2(255),
            last_name           varchar2(255),
            day_phone           varchar2(255),
            address             varchar2(255),
            city                varchar2(255),
            state               varchar2(255),
            zip                 varchar2(255),
            email               varchar2(255),
            birth_date          varchar2(255),
            employer_name       varchar2(255),
            full_name           varchar2(255),
            effective_date      varchar2(255),
            annual_election     varchar2(255),
            division_name       varchar2(255),
            deductible          varchar2(255),
            cov_tier_name       varchar2(255),
            effective_end_date  varchar2(255),
            plan_start_date     varchar2(255),
            plan_end_date       varchar2(255),
            pay_cycle           varchar2(255),
            first_payroll_date  varchar2(255),
            pay_contribution    varchar2(255),
            acc_num             varchar2(255),
            gender              varchar2(10) 				---- 8669 rprabu 23/01/2020
            ,
            debit_card          varchar2(20)   		    ---- 8669 rprabu 23/01/2020
            ,
            payment_start_date  varchar2(255)     		    ---- 8669 rprabu 23/01/2020
            ,
            recurring_frequency varchar2(255)    			---- 8669 rprabu 23/01/2020
            ,
            no_of_pay_periods   number(4)    			    ---- 8669 rprabu 23/01/2020
            ,
            plan_type           varchar2(255)              ---- 8669 rprabu 23/01/2020
            ,
            funding_type        varchar2(255)              ---- 8669 rprabu 23/01/2020
            ,
            plan_code           varchar2(255)              ---- 8669 rprabu 23/01/2020
            ,
            scheduler_id        varchar2(255)              ---- 8669 rprabu 23/01/2020
            ,
            invoice_type        varchar2(255)             ---- 8669 rprabu 23/01/2020
            ,
            er_amount           number(7, 2),
            ee_amount           number(7, 2)
    );
    type member_t is
        table of member_row;
    type dependent_row is record (
            ssn            varchar2(30),
            subscriber_ssn varchar2(30),
            first_name     varchar2(255),
            middle_name    varchar2(255),
            last_name      varchar2(255),
            day_phone      varchar2(255),
            address        varchar2(255),
            city           varchar2(255),
            state          varchar2(255),
            zip            varchar2(255),
            birth_date     varchar2(255),
            relation       varchar2(255)
    );
    type dependent_t is
        table of dependent_row;
    type plan_detail_row is record (
            plan_type_meaning varchar2(255),
            plan_type         varchar2(255),
            plan_start_date   varchar2(255),
            plan_end_date     varchar2(255),
            effective_date    varchar2(255),
            annual_election   number,
            contribution_ytd  number,
            disbursement_ytd  number,
            available_balance number
    );
    type plan_detail_t is
        table of plan_detail_row;
    type deposit_row is record (
            acc_num         varchar2(255),
            first_name      varchar2(255),
            last_name       varchar2(255),
            ee_contribution number,
            er_contribution number,
            total_amount    number,
            plan_type       varchar2(255),
            division_name   varchar2(255),
            fee_date        varchar2(255)
    );
    type deposit_t is
        table of deposit_row;
    type enrollee_balance_row is record (
            acc_num                     varchar2(30),
            first_name                  varchar2(255),
            last_name                   varchar2(255),
            termination_date            varchar2(30),
            plan_start_date             varchar2(30),
            annual_election             varchar2(30),
            acc_balance                 varchar2(30),
            deposit                     varchar2(30),
            disbursement                varchar2(30),
            plan_type_meaning           varchar2(255),
            plan_type                   varchar2(255),
            division_code               varchar2(255),
            division_name               varchar2(255),
            name                        varchar2(255),
            claims_paid_ytd             number,
            rollover                    number       		 -- Added By Swamy For Ticket#5824
            ,
            annual_election_wo_rollover number          -- Added By Rprabu For Ticket#5824
    );
    type enrollee_balance_t is
        table of enrollee_balance_row;
    type plan_yearend_row_t is record (
            plan_type           varchar2(50),
            plan_type_meaning   varchar2(50),
            effective_date      varchar2(50),
            effective_end_date  varchar2(50),
            runout_date         varchar2(50),
            grace_period        varchar2(50),
            max_rollover_amount varchar2(50)
    );
    type plan_yearend_t is
        table of plan_yearend_row_t;
    type revenue_row_t is record (
            check_year   number,
            check_mon    varchar2(30),
            check_mm     number,
            setup_fee    number,
            monthly_fee  number,
            other_fee    number,
            renewal_fee  number,
            account_type varchar2(30)
    );
    type revenue_t is
        table of revenue_row_t;
    type suspended_cards_row_t is record (
            acc_num       varchar2(30),
            first_name    varchar2(255),
            middle_name   varchar2(30),
            last_name     varchar2(255),
            employer_name varchar2(255),
            employee_name varchar2(255),
            acc_id        number,
            pers_id       number,
            entrp_id      number,
            no_of_unsub   number,
            card_number   varchar2(30),
            division_code varchar2(255)
    );
    type suspended_cards_t is
        table of suspended_cards_row_t;
    function get_dvsn_cd (
        p_division_code varchar2 default null
    ) return varchar2;

    function get_acc_count (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null,
        p_status        in varchar2
    ) return number;

    function get_all_acc_count (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_status        in varchar2,
        p_month         in number default null,
        p_year          in number default null
    ) return number;

    function get_card_count (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null
    ) return number;

    function get_card_not_active_count (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null
    ) return number;

    function get_ben_count (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null
    ) return number;

    function get_active_user_count (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null
    ) return number;

    function get_er_online_accounts (
        p_entrp_id in number
    ) return ret_er_online_accounts_t
        pipelined
        deterministic;

    function get_acc_email_count (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null
    ) return number;

    function get_acc_balance (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null
    ) return number;

    function get_acc_inv_bal (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null
    ) return number;

    function get_overview_summary (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null
    ) return overview_t
        pipelined
        deterministic;

    function get_feature_summary (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null
    ) return feature_t
        pipelined
        deterministic;

    function get_balance_summary (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null
    ) return balance_t
        pipelined
        deterministic;

    function get_balance_range (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null
    ) return balance_range_t
        pipelined
        deterministic;

    function get_outside_inv_range (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null
    ) return balance_range_t
        pipelined
        deterministic;

    function get_total_bal_range (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null
    ) return balance_range_t
        pipelined
        deterministic;

    function get_contribution_summary (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null
    ) return transaction_t
        pipelined
        deterministic;

    function get_ytd_contribution_summary (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null
    ) return transaction_t
        pipelined
        deterministic;

    function get_disbursement_summary (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null
    ) return transaction_t
        pipelined
        deterministic;

    function get_ytd_disbursement_summary (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null
    ) return transaction_t
        pipelined
        deterministic;

    function get_spender_saver_summary (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null
    ) return spend_save_t
        pipelined
        deterministic;

    function get_disb_detail_summary (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null
    ) return disb_detail_t
        pipelined
        deterministic;

    function get_ytd_disb_detail_summary (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null
    ) return disb_detail_t
        pipelined
        deterministic;

    function get_disb_breakdown_summary (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null
    ) return disb_breakdown_t
        pipelined
        deterministic;

    function get_ytd_disb_breakdown_summary (
        p_entrp_id      in number,
        p_division_code varchar2 default null,
        p_month         in number default null,
        p_year          in number default null
    ) return disb_breakdown_t
        pipelined
        deterministic;

    function get_hra_fsa_active_plans return plans_t
        pipelined
        deterministic;

    function get_ex_hra_fsa_active_plans return plans_t
        pipelined
        deterministic;

   -- For Assets Under Management
   -- Deposits
    function get_all_deposit_summary (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_from_date    in varchar2,
        p_to_date      in varchar2
    ) return all_deposits_t
        pipelined
        deterministic;

    function get_all_fee_summary (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_from_date    in varchar2,
        p_to_date      in varchar2
    ) return all_deposits_t
        pipelined
        deterministic;

    function get_all_payment_summary (
        p_account_type in varchar2,
        p_plan_sign    in varchar2,
        p_from_date    in varchar2,
        p_to_date      in varchar2
    ) return all_deposits_t
        pipelined
        deterministic;

    procedure export_transaction (
        p_account_type     in varchar2,
        p_plan_sign        in varchar2,
        p_from_date        in varchar2,
        p_to_date          in varchar2,
        p_transaction_type in varchar2
    );

    function get_hra_sfhso_contribution (
        p_acc_num in varchar2
    ) return contribution_t
        pipelined
        deterministic;

    function get_hra_sfhso_exp_funds_rep return expire_funds_t
        pipelined
        deterministic;

    function get_benefit_plans (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return plan_info_t
        pipelined
        deterministic;

    function get_claims (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_start_date      in date,
        p_end_date        in date,
        p_plan_type       in varchar2,
        p_division_code   in varchar2,
        p_report_type     in varchar2
    ) return claim_t
        pipelined
        deterministic;

    function get_member_claims (
        p_acc_num         in varchar2,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_start_date      in date,
        p_end_date        in date,
        p_plan_type       in varchar2,
        p_division_code   in varchar2,
        p_report_type     in varchar2
    ) return claim_t
        pipelined
        deterministic;

    function get_member (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2
    ) return member_t
        pipelined
        deterministic;

    function get_dependent (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2
    ) return dependent_t
        pipelined
        deterministic;

    function get_member_detail (
        p_acc_num in varchar2
    ) return member_t
        pipelined
        deterministic;

    function get_plan_detail (
        p_acc_num         in varchar2,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_report_type     in varchar2 default 'ENROLLEE_BALANCE'
    ) return plan_detail_t
        pipelined
        deterministic;

    function get_sford_plan_detail (
        p_acc_num         in varchar2,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_report_type     in varchar2 default 'ENROLLEE_BALANCE'
    ) return plan_detail_t
        pipelined
        deterministic;

    function get_contribution (
        p_entrp_id      in number,
        p_start_date    in date,
        p_end_date      in date,
        p_plan_type     in varchar2,
        p_division_code in varchar2,
        p_report_type   in varchar2
    ) return deposit_t
        pipelined
        deterministic;

    function get_enrollee_balance (
        p_entrp_id        in number,
        p_start_date      in date,
        p_end_date        in date,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2,
        p_division_code   in varchar2
    ) return enrollee_balance_t
        pipelined
        deterministic;

    function get_pending_member (
        p_entrp_id  in number,
        p_plan_type in varchar2
    ) return member_t
        pipelined
        deterministic;

    function get_yearend_summary (
        p_acc_num in varchar2
    ) return plan_yearend_t
        pipelined
        deterministic;

    function get_revenue_summary (
        p_account_type in varchar2
    ) return revenue_t
        pipelined
        deterministic;

    function get_approved_member (
        p_entrp_id     in number,
        p_batch_number in number,
        p_plan_type    in varchar2
    ) return member_t
        pipelined
        deterministic;

    function f_pending_doc_hrafsa_claims (
        p_acc_id in number
    ) return claim_t
        pipelined
        deterministic;

    function get_hra_ndt_member (
        p_entrp_id in number
    ) return member_t
        pipelined
        deterministic;

    function get_fsa_ndt_member (
        p_entrp_id in number
    ) return member_t
        pipelined
        deterministic;

    function get_enrollee_balance_rep (
        p_entrp_id      in number,
        p_start_date    in date,
        p_end_date      in date,
        p_ben_plan_id   in number,
        p_division_code in varchar2
    ) return enrollee_balance_t
        pipelined
        deterministic;

    procedure write_funding_exception_file;

    procedure write_detail_funding_file;

    procedure write_funding_report_file;

    function get_suspended_cards_rep (
        p_entrp_id      in number,
        p_division_code in varchar2
    ) return suspended_cards_t
        pipelined
        deterministic;

    function get_renewal_template (
        p_entrp_id in number
    ) return member_t
        pipelined
        deterministic;

/* Procedure created by Jagadeesh for Ticket# */
--PROCEDURE Monthly_contri_audit_detail( p_start_date date default NULL,p_end_date date  default NULL) ;   -- This Development is on Hold so commenting it
  -- Added by Swamy for Ticket#9669
    type welcome_letter_row_t is record (
            today           varchar2(20),
            er_name         varchar2(200),
            er_contact      varchar2(200),
            address         varchar2(500),
            city            varchar2(200),
            acc_num         varchar2(200),
            year            varchar2(200),
            account_type    varchar2(200),
            lang_perf       varchar2(200),
            template_name   varchar2(200),
            initial_contrib number,
            month_setup     number,
            single_contrib  varchar2(200),
            family_contrib  varchar2(200),
            individual_name varchar2(200)
    );
    type welcome_letter_t is
        table of welcome_letter_row_t;
  -- Added by Swamy for Ticket#9669
    type account_row_t is record (
            account_type  varchar2(20),
            name          varchar2(500),
            error_message varchar2(200),
            email         varchar2(100)
    );
    type account_t is
        table of account_row_t;
-- Added by Swamy for Ticket#9669
    function get_account_details (
        p_acc_num      in varchar2,
        p_flg_employer in varchar2
    ) return account_t
        pipelined
        deterministic;

-- Added by Swamy for Ticket#9669
    function get_welcome_letters (
        p_acc_num      in varchar2,
        p_flg_employer in varchar2
    ) return welcome_letter_t
        pipelined
        deterministic;

-- Added by 12157- Claims Aging Report
    type claim_aging_row is record (
            emp_name      varchar2(250),
            acc_num       varchar2(20),
            claim_id      number,
            claim_status  varchar2(255),
            received_days number,
            no_of_days    number,
            payment_type  varchar2(255)
    );
    type claim_aging_t is
        table of claim_aging_row;
    function generate_claim_aging_report return claim_aging_t
        pipelined
        deterministic;

end pc_reports_pkg;
/


-- sqlcl_snapshot {"hash":"fbe3c73955fad5526ee48d528d47fb27212680b4","type":"PACKAGE_SPEC","name":"PC_REPORTS_PKG","schemaName":"SAMQA","sxml":""}