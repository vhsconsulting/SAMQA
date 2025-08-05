-- liquibase formatted sql
-- changeset SAMQA:1754374138849 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_lookups.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_lookups.sql:null:688f6616b579423873d26bdd358dc2d768d574e7:create

create or replace package samqa.pc_lookups as
    function get_plan_type (
        p_code in varchar2
    ) return varchar2;

    function get_fsa_plan_type (
        p_code in varchar2
    ) return varchar2;

    function get_employer (
        p_entrp_id in number
    ) return varchar2;

    function get_broker (
        p_broker_id in number
    ) return varchar2;

    function get_account_status (
        p_acc_status in number
    ) return varchar2;

    function get_fee_reason (
        p_reason_code in number
    ) return varchar2;

    function get_bank_acct_type (
        p_bank_acct_type in varchar2
    ) return varchar2;

    function get_bank_acct_usage (
        p_bank_acct_usage in varchar2
    ) return varchar2;

    function get_ach_status (
        p_acc_status in number
    ) return varchar2;

    function get_web_expense_type (
        p_expense_code in varchar2
    ) return varchar2;

    function get_expense_type (
        p_expense_code in varchar2
    ) return varchar2;

    function get_expense_type_short (
        p_expense_code in varchar2
    ) return varchar2;

    function get_reason_name (
        p_reason_code in number
    ) return varchar2;

    function get_claim_type (
        p_claim_type in varchar2
    ) return varchar2;

    function get_enrollment_source (
        p_code in varchar2
    ) return varchar2;

    function get_relat_code (
        p_code in varchar2
    ) return varchar2;

    function get_account_type (
        p_acc_type in varchar2
    ) return varchar2;

    function get_card_allowed (
        p_lookup_code in varchar2
    ) return varchar2;

    function get_pay_period (
        p_lookup_code in varchar2
    ) return varchar2;

    function get_pay_type (
        p_lookup_code in varchar2
    ) return varchar2;

    function get_er_reimbursement_type (
        p_lookup_code in varchar2
    ) return varchar2;

    function get_funding_options (
        p_lookup_code in varchar2
    ) return varchar2;

    function get_funding_type (
        p_lookup_code in varchar2
    ) return varchar2;

    function get_nhire_contrib (
        p_lookup_code in varchar2
    ) return varchar2;

    function get_emp_reg_type (
        p_lookup_code in varchar2
    ) return varchar2;

    function get_title (
        p_lookup_code in varchar2
    ) return varchar2;

    function get_payroll_frequncy (
        p_lookup_code in varchar2
    ) return varchar2;

    function get_hra_bps_action (
        p_code in varchar2
    ) return varchar2;

    function get_claim_status (
        p_lookup_code in varchar2
    ) return varchar2;

    function get_denied_reason (
        p_lookup_code in varchar2
    ) return varchar2;

    function get_pay_code (
        p_lookup_code in varchar2
    ) return varchar2;

    function get_meaning (
        p_lookup_code in varchar2,
        p_lookup_name in varchar2
    ) return varchar2;

    function get_plan_type_code (
        p_plan_type varchar2
    ) return varchar2;

   -- 4/23/2011 changes
    function get_claim_medical_code (
        p_lookup_code in varchar2
    ) return varchar2;

    procedure insert_lookups (
        p_lookup_code in varchar2,
        p_lookup_name in varchar2,
        p_meaning     in varchar2
    );
	--below code added by preethy starts here
    type varchar2_tbl is
        table of varchar2(3200) index by binary_integer;
    function array_fill (
        p_array       varchar2_tbl,
        p_array_count number
    ) return varchar2_tbl;

    procedure update_mobile_version (
        p_lookup_code   in varchar2_tbl,
        p_meaning       in varchar2_tbl,
        x_error_message out varchar2,
        x_return_status out varchar2
    );
 --code added by preethy ends here

--added by vanitha
    function get_code (
        p_meaning     in varchar2,
        p_lookup_name in varchar2
    ) return varchar2;

-- Added by jaggi ##9392
    type get_lookup_values_row_t is record (
            lookup_code varchar2(100),
            description varchar2(255)
    );
    type get_lookup_values_t is
        table of get_lookup_values_row_t;
    function get_lookup_values (
        p_lookup_name varchar2
    ) return get_lookup_values_t
        pipelined
        deterministic;
-- Added by Joshi for 10742
    function get_amendment_fee (
        p_account_type in varchar2
    ) return number;

-- Added by Jaggi for 11192
    function get_hawaii_tax_rate (
        p_city_name in varchar2
    ) return number;

-- Added by Joshi for 11119
    function get_fsa_hra_monthly_fee (
        p_plan_type in varchar2
    ) return number;

end;
/

