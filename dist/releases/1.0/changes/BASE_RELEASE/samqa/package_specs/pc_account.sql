-- liquibase formatted sql
-- changeset SAMQA:1754374133898 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_account.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_account.sql:null:ba16e5435125be6c01ca88c1353d526606b42b0f:create

create or replace package samqa.pc_account is

/*
  30.06.2006 mal + reopen_account
  07.02.2006 mal  year_income - include next year (7)
                  acc_balance - speed up using view acc_bal
  02.02.2006 mal + year_income
  07.06.2005 mal + acc_balance_card
  25.03.2005 mal + account_close, Change_Plan
  21.03.2005 mal + is_account_open , is_account_close
*/
    type hsa_acct_record_t is record (
            hsa_cnt       number,
            error_message varchar2(1000),
            error_status  varchar2(10)
    );
    type hsa_act_acct_t is
        table of hsa_acct_record_t;
    type rec_hsa is record (
            age       number,
            contrib   number,
            plan_type varchar2(15),
            max_limit number
    );
    type tbl_hsa is
        table of rec_hsa;
    type acc_pref_rec_t is record (
            acc_id                    number,
            entrp_id                  number,
            paper_doc                 varchar2(1),
            preferred_language        varchar2(25),
            claim_payment_method      varchar2(5),
            status                    varchar2(10),
            autopay_ind               varchar2(30),
            plan_only                 varchar2(30),
            allow_eob                 varchar2(1),
            pin_mailer_allowed        varchar2(1),
            teamster_group            varchar2(1),
            allow_exp_enroll          varchar2(1),
            er_contribution_frequency number,
            ee_contribution_frequency number,
            er_contribution_flag      number,
            ee_contribution_flag      number,
            setup_fee_paid_by         number,
            maint_fee_paid_by         number
    );
    type acc_pref_t is
        table of acc_pref_rec_t;

-- Added by Joshi for 6792
    type rec_ameritrade_acct is record (
            acc_id              number,
            account_number      varchar2(20),
            hsa_balance         number,
            outside_inv_balance number,
            acct_requested      varchar2(1)
    );
    type tbl_ameritrade_acct is
        table of rec_ameritrade_acct;
-- code ends:6792

    procedure end_date_employer;

    procedure remove_employer;

    function get_acc_num (
        p_mass_enrollment_id in number
    ) return varchar2;

    function get_outside_investment (
        p_acc_id in number
    ) return number;

    function check_online_account (
        p_acc_id in number
    ) return varchar2;

    function get_account_type (
        p_acc_id in number
    ) return varchar2;

    function get_account_type_from_pers_id (
        p_pers_id in number
    ) return varchar2;

    function get_broker (
        p_broker_id in number
    ) return varchar2;

    function has_baa_document (
        p_acc_id in number
    ) return varchar2;

    function get_carrier (
        p_carrier_id in number
    ) return varchar2;

    function get_hra_plan_year_balance (
        acc_id_in     in account.acc_id%type,
        date_start_in in date default trunc(sysdate, 'cc'),
        date_end_in   in date default sysdate
    ) return number;

    function get_hra_balance (
        acc_id_in     in account.acc_id%type,
        date_start_in in date default trunc(sysdate, 'cc'),
        date_end_in   in date default sysdate
    ) return number;

    function acc_balance (
        acc_id_in      in account.acc_id%type,
        date_start_in  in date default trunc(sysdate, 'cc'),
        date_end_in    in date default sysdate,
        p_account_type in varchar2 default 'HSA',
        p_plan_type    in varchar2 default null,
        p_start_date   in date default null,
        p_end_date     in date default null
    ) return number;

    function have_outside_investment (
        p_acc_id in number
    ) return varchar2;

--  all incomes
    function acc_income (
        acc_id_in     in income.acc_id%type,
        date_start_in in date default trunc(sysdate, 'cc'),
        date_end_in   in date default sysdate
    ) return number;

    function acc_fee (
        acc_id_in     in income.acc_id%type,
        date_start_in in date default trunc(sysdate, 'cc'),
        date_end_in   in date default sysdate
    ) return number;

    function acc_interest (
        acc_id_in     in income.acc_id%type,
        date_start_in in date default trunc(sysdate, 'cc'),
        date_end_in   in date default sysdate
    ) return number;

    function lost_card_fee (
        acc_id_in     in income.acc_id%type,
        date_start_in in date default trunc(sysdate, 'cc'),
        date_end_in   in date default sysdate
    ) return number;

    function check_cutting_fee (
        acc_id_in     in income.acc_id%type,
        date_start_in in date default trunc(sysdate, 'cc'),
        date_end_in   in date default sysdate
    ) return number;
-- income in year, but not interest(8) and prev.year(7)
    function year_income (
        acc_id_in     in income.acc_id%type,
        date_start_in in date default trunc(sysdate, 'yyyy') -- any date in year
        ,
        date_end_in   in date default sysdate -- no need now, spare for future.
    ) return number;
--  pay from account
    function acc_payment (
        acc_id_in     in payment.acc_id%type,
        date_start_in in date default trunc(sysdate, 'cc'),
        date_end_in   in date default sysdate
    ) return number;
--  Balance in account
/*FUNCTION acc_balance(
   acc_id_in IN ACCOUNT.acc_id%TYPE
  ,date_start_in IN DATE DEFAULT TRUNC(SYSDATE, 'cc')
  ,date_end_in IN DATE DEFAULT SYSDATE
) RETURN NUMBER;
*/
    function current_hrafsa_balance (
        acc_id_in          in account.acc_id%type,
        date_start_in      in date default trunc(sysdate, 'cc'),
        date_end_in        in date default sysdate,
        plan_start_date_in in date default trunc(sysdate, 'YYYY'),
        plan_end_date_in   in date default add_months(
            trunc(sysdate, 'YYYY'),
            12
        ),
        p_plan_type        in varchar2 default null
    ) return number;

    function current_balance (
        acc_id_in      in account.acc_id%type,
        date_start_in  in date default trunc(sysdate, 'cc'),
        date_end_in    in date default sysdate,
        p_account_type in varchar2 default 'HSA',
        p_plan_type    in varchar2 default null
    ) return number;

-- Balance in debit card
    function acc_balance_card (
        acc_id_in     in account.acc_id%type  -- ???? ?????? ???? - ?? ?? ????? ??????
        ,
        pers_id_in    in account.pers_id%type default null  -- ???? ??????? - ?? ?????? ?? ?? ?????
        ,
        date_start_in in date default trunc(sysdate, 'cc'),
        date_end_in   in date default sysdate
    ) return number;
/* is account acc_id_in open at date_in
  1=open  0=close  NULL = no such account */
    function is_account_open (
        acc_id_in in account.acc_id%type,
        date_in   in date default sysdate
    ) return number;
/* is account acc_id_in closed at date_in 1=close 0=open */
    function is_account_close (
        acc_id_in in account.acc_id%type,
        date_in   in date default sysdate
    ) return number;

    procedure close_account (
        acc_id_in        in account.acc_id%type,
        date_in          in date --  ???? ???????? ????? ?????
        ,
        note_in          in account.note%type,
        closed_reason_in in varchar2 default 'MEMBER_REQUEST'
    );

    procedure change_plan (
        acc_id_in in account.acc_id%type,
        date_in   in date,
        plan_in   in account.plan_code%type,
        note_in   in account.note%type
    );

    procedure upgrade_account (
        acc_id_in in account.acc_id%type,
        date_in   in date,
        plan_in   in account.plan_code%type,
        note_in   in account.note%type,
        p_user_id in number default 0
    );

    procedure reopen_account (
        acc_id_in in account.acc_id%type,
        date_in   in date default trunc(sysdate),
        note_in   in account.note%type default null
    );

    function get_initial_contribution (
        acc_id_in in account.acc_id%type
    ) return number;

    function validate_subscriber (
        p_acc_id in number,
        p_setup  in number,
        p_status in number
    ) return varchar2;

    function validate_enrollment (
        p_acc_id in number
    ) return varchar2;

    function get_employer_status (
        entrp_id_in   in number,
        start_date_in in varchar2,
        end_date_in   in varchar2
    ) return varchar2;

    procedure reset_card_status;

    function get_salesrep_id (
        p_pers_id  in number,
        p_entrp_id in number
    ) return number;

    function get_salesrep (
        broker_id_in in number
    ) return varchar2;
/*Sk Added on 11/09/2023*/
    function get_employer_name (
        acc_id_in in number
    ) return varchar2;

    function get_person_name (
        acc_id_in in number
    ) return varchar2;

    function get_salesrep_name (
        sales_rep_in in number
    ) return varchar2;

    function fee_bucket_balance (
        acc_id_in     in account.acc_id%type,
        date_start_in in date default trunc(sysdate, 'cc'),
        date_end_in   in date default sysdate
    ) return number;

    function outside_inv_balance (
        acc_id_in   in account.acc_id%type,
        date_end_in in date default sysdate
    ) return number;

    procedure assign_broker (
        p_broker_id      in number,
        p_pers_id        in number,
        p_acc_id         in number,
        p_entrp_id       in number,
        p_effective_date in varchar2,
        p_user_id        in number
    );

    function check_duplicate (
        p_ssn           in varchar2,
        p_group_acc_num in varchar2,
        p_emp_name      in varchar2,
        p_account_type  in varchar2,
        p_entrp_id      in number
    ) return varchar2;

    procedure create_catchup_account (
        p_pers_id       in number,
        p_user_id       in number,
        x_error_message out varchar2
    );

    function get_acc_id (
        p_acc_num in varchar2
    ) return number;

    function get_acc_num_from_acc_id (
        p_acc_id in number
    ) return varchar2;

    function get_acc_id_from_ssn (
        p_ssn      in varchar2,
        p_entrp_id in number
    ) return number;

    function get_account_status (
        p_acc_id in number
    ) return number;

    function get_status (
        p_acc_id in number
    ) return varchar2;

    procedure upsert_acc_pref (
        p_entrp_id               in number,
        p_acc_id                 in number,
        p_claim_pay_method       in varchar2,
        p_auto_pay               in varchar2,
        p_plan_doc_only          in varchar2,
        p_status                 in varchar2,
        p_allow_eob              in varchar2,
        p_user_id                in number,
        p_pin_mailer             in varchar2 default 'N',
        p_teamster_group         in varchar2 default 'N',
        p_allow_exp_enroll       in varchar2 default 'Y',
        p_maint_fee_paid         in number default null,
        p_allow_online_renewal   in varchar2,
        p_allow_election_changes in varchar2,
        p_plan_action_flg        in varchar2 default 'Y',
        p_submit_election_change in varchar2 default 'Y',
        p_edi_flag               in varchar2 default 'N'   -- Added by Swamy on 11/06/2018 wrt Ticket#5863, adding EDI flag and Vendor ID
        ,
        p_vendor_id              in number default null    -- Added by Swamy on 11/06/2018 wrt Ticket#5863, adding EDI flag and Vendor ID
        ,
        p_reference_flag         in varchar2  --Code added by preethy for ticket No:#6071 on 05/07/2018
        ,
        p_allow_payroll_edi      in varchar2  --Code added  by preethy for ticket No:6300 on 16/07/2018
        ,
        p_allow_broker_enroll    in varchar2 default null /*Ticket#6834 */,
        p_allow_broker_renewal   in varchar2 default null,
        p_allow_broker_invoice   in varchar2 default null,
        p_fees_paid_by           in varchar2 default null    -- Added by Swamy for Ticket#11037
    );

    function get_cobra_url (
        p_name   in varchar2,
        p_tax_id in varchar2,
        p_lookup in varchar2
    ) return varchar2;

    function get_hex_acc_list (
        p_tax_id in varchar2
    ) return varchar2;

    function new_acc_balance (
        acc_id_in      in account.acc_id%type,
        date_start_in  in date default trunc(sysdate, 'cc'),
        date_end_in    in date default sysdate,
        p_account_type in varchar2 default 'HSA',
        p_plan_type    in varchar2 default null,
        p_start_date   in date default null,
        p_end_date     in date default null
    ) return number;

    function is_stacked_account (
        p_entrp_id in number
    ) return varchar2;

    procedure insert_acc_pref (
        p_acc_pref in acc_pref_t,
        p_userid   in number,
        p_status   out varchar2,
        p_error    out varchar2
    );

    function active_hsa_acct (
        p_ssn in varchar2
    ) return hsa_act_acct_t
        pipelined
        deterministic;

    function generate_acc_num (
        p_plan_code in number,
        p_state     in varchar2
    ) return varchar2;

-- Called from website
    function is_payroll_integrated (
        p_entrp_id number
    ) return varchar2;

    function enable_plan_action (
        p_entrp_id number
    ) return varchar2;

    function show_submit_elec_chng (
        p_entrp_id number
    ) return varchar2;

    function previous_acc_balance (
        acc_id_in      in account.acc_id%type,
        date_start_in  in date default trunc(sysdate, 'cc'),
        date_end_in    in date default sysdate,
        p_account_type in varchar2 default 'HSA',
        p_plan_type    in varchar2 default null,
        p_start_date   in date default null,
        p_end_date     in date default null
    ) return number;

-- Added by swamy on 11/06/2018 wrt Ticket#5863
-- Function will be calledfrom Apex page 39 to retrive the vendor name based on vendoe ID.
    function get_vendor_name (
        p_vendor_id in number
    ) return varchar2;

-- Added by Swamy wrt Ticket#6794: ACN Migration
    function is_migrated (
        p_acc_id number
    ) return varchar2;

-- Added by Swamy wrt Ticket#6794: ACN Migration
    function get_plan_code (
        p_acc_id in number
    ) return number;

-- Added by Joshi wrt Ticket#6794: ACN Migration
    function get_emp_accid_from_pers_id (
        p_pers_id number
    ) return number;

--Added by Joshi for 6796
    function get_ameritrade_acct_detail (
        p_acc_id number
    ) return tbl_ameritrade_acct
        pipelined
        deterministic;

    procedure create_outside_investment (
        p_claim_id      number,
        p_user_id       number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure close_all_accounts;   -- Added By Swamy For Ticket#7568

--Added by Joshi for 9072
    function get_edi_flag (
        p_tax_id in varchar2
    ) return varchar2;

-- Added by Swamy for Ticket#9912 on 10/08/2021
    function get_account_type_from_entrp_id (
        p_entrp_id in number
    ) return varchar2;

  -- Added by Swamy for Ticket#10104 on 21/09/2021
    function check_minimum_balance (
        p_acc_id       in number,
        p_account_type in varchar2,
        p_start_date   in date,
        p_end_date     in date
    ) return varchar2;

-- Added by Swamy for Ticket#10431(Renewal Resubmit)
    function get_renewal_resubmit_flag (
        p_entrp_id in number
    ) return varchar2;

-- Added by Jaggi for #11128
    function check_flg_agree (
        p_acc_id number
    ) return varchar2;

    procedure update_agreement_flag (
        p_user_id   number,
        p_acc_id    in number,
        p_flg_agree in varchar2
    );

-- Added by Swamy for Ticket#11106 to find the Stacked Account.
    function is_stacked_account_new (
        p_entrp_id in number
    ) return varchar2;
-- Added by Jaggi #11263
    function get_broker_id (
        p_acc_id in number
    ) return number;
-- Added by Jaggi #11263
    function get_ga_id (
        p_acc_id in number
    ) return number;

-- Added by Joshi for closing QB accounts.
    procedure close_qb_accounts (
        p_entrp_id  number,
        p_term_date date,
        p_user_id   number
    );

    procedure terminate_cobra_employer;
--- Added by rprabu 26/07/2023
    procedure terminate_cobra_qb_employees; 	
-- Added by Jaggi #11629
    function get_salesrep_email (
        p_entrp_id in number
    ) return varchar2;

--- 14/07/2023 rprabu used in COBRA Apex Page 36 for closing QB
    procedure close_qb_ee_account (
        p_pers_id   number,
        p_term_date date,
        p_user_id   number
    );

-- Added by Joshi for 12006
    function get_acc_num_from_ssn (
        p_ssn in varchar2
    ) return varchar2;

end pc_account;
/

