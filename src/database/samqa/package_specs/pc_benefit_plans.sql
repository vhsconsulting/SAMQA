create or replace package samqa.pc_benefit_plans as
    max_rollover_amount number := 660; -- Added by Joshi for ticket 12413

  -- Added Type by Swamy for DB Upgrade on 17/08/2021
    type rec_benefit_codes is record (
            benefit_code_id    number,
            benefit_code_name  varchar2(100),
            description        varchar2(1000),
            fully_insured_flag varchar2(1),
            self_insured_flag  varchar2(1),
            check_box          varchar2(1)
    );
    type tbl_benefit_codes is
        table of rec_benefit_codes;

  -- FUNCTION TO CHECK DUPLICATE PLANS FOR NON FSA/HRA PRODUCTS
    function check_dup_plans (
        p_acc_id          in number,
        p_plan_type       in varchar2,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_number     in varchar2
    ) return varchar2;
    -- FUNCTION TO CHECK DUPLICATE PLANS FOR  FSA/HRA PRODUCTS

    function check_dup_plan_type (
        p_acc_id          in number,
        p_plan_type       in varchar2,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return varchar2;

    function check_validity (
        p_acc_id          in number,
        p_plan_type       in varchar2,
        p_annual_election in number,
        p_effective_date  in date,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return varchar2;

    function get_ben_plan (
        p_er_ben_plan_id in number,
        p_acc_id         in number
    ) return number;

    function get_ben_plan_status (
        p_er_ben_plan_id in number,
        p_acc_id         in number
    ) return varchar2;

    function get_annual_election (
        p_er_ben_plan_id in number,
        p_acc_id         in number
    ) return number;

    function get_ben_plan_type (
        p_ben_plan_id in number
    ) return varchar2;

    function get_ben_account_type (
        p_acc_id in number
    ) return varchar2;

    function get_entrp_ben_account_type (
        p_entrp_id in number
    ) return varchar2;

    function get_hra_ben_plan_type (
        p_acc_id       in number,
        p_account_type in varchar2
    ) return varchar2;

    function get_ee_annual_election (
        p_acc_id    in number,
        p_plan_type in varchar2
    ) return number;

    function get_ee_annual_election (
        p_acc_id          in number,
        p_plan_type       in varchar2,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return number;

    procedure end_date_benefit_plans;

    procedure add_renew_employees (
        p_acc_id          in number,
        p_annual_election in number,
        p_er_ben_plan_id  in number,
        p_user_id         in number,
        p_cov_tier_name   in varchar2 default null,
        p_effective_date  in date default null,
        p_batch_number    in number,
        x_return_status   out varchar2,
        x_error_message   out varchar2,
        p_status          in varchar2 default 'A',
        p_life_event_code in varchar2 default null
    );

    procedure create_annual_election (
        p_batch_number  in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    function get_er_ben_plan (
        p_entrp_id       in number,
        p_plan_type      in varchar2,
        p_effective_date in date
    ) return number;

    function get_cov_tier_name (
        p_er_ben_plan_id in number,
        p_acc_id         in number
    ) return varchar2;

    function get_deductible (
        p_er_ben_plan_id in number,
        p_acc_id         in number
    ) return varchar2;

    procedure insert_benefit_plan (
        p_er_ben_plan_id  in number,
        p_acc_id          in number,
        p_effective_date  in varchar2,
        p_annual_election in number,
        p_coverage_level  in varchar2,
        p_batch_number    in number default null,
        p_cov_tier_name   in varchar2 default null,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    );

    procedure insert_benefit_plan (
        p_er_ben_plan_id  in number,
        p_acc_id          in number,
        p_effective_date  in varchar2,
        p_annual_election in number,
        p_coverage_level  in varchar2,
        p_eob_required    in varchar2 default null,
        p_batch_number    in number default null,
        p_cov_tier_name   in varchar2 default null,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    );

    procedure create_benefit_coverage (
        p_er_ben_plan_id in number,
        p_cov_tier_name  in varchar2,
        p_acc_id         in number default null,
        p_user_id        in number,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    );

    procedure create_fsa_coverage (
        p_ben_plan_id   in number,
        p_cov_tier_name in varchar2,
        p_user_id       in number
    );

    procedure update_deductible_rule (
        p_er_ben_plan_id in number
    );

    procedure update_employees_coverage (
        p_er_ben_plan_id in number,
        p_tier_name      in varchar2,
        p_deductible     in number
    );

    procedure hra_rollover (
        p_entrp_id      in number,
        p_ben_plan_id   in number,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure enable_sfo (
        p_sf_flg        in varchar,
        p_ben_plan_id   in number,
        p_qtly_date     in date,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    function get_effective_date (
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date,
        p_plan_type  in varchar2
    ) return date;

    function get_frequency (
        p_entrp_id      in number,
        p_pay_cycle     in varchar2,
        p_eff_date      in varchar2,
        p_plan_end_date in varchar2
    ) return number;

    function calculate_pay_period (
        p_plan_type     in varchar2,
        p_entrp_id      in number,
        p_ann_election  in number,
        p_pay_cycle     in varchar2,
        p_eff_date      in varchar2,
        p_plan_end_date in varchar2
    ) return number;
  -- Update the plans nightly to update dates, renewal dates, product type
    procedure update_plans_nightly;

    procedure hra_fsa_rollover (
        p_entrp_id      in number,
        p_ben_plan_id   in number,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    function display_coverage_tier (
        p_plan_type    in varchar2,
        p_grace_period in number,
        p_ben_plan_id  in number
    ) return varchar2;

    procedure add_fsa_cov_tier (
        p_ben_plan_id   in number,
        p_entrp_id      in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure create_pop_plan (
        p_acc_id in number
    );

    procedure insert_plan_notice (
        p_entrp_id    in number,
        p_plan_type   in varchar2,
        p_notice_type in varchar2,
        p_user_id     in number
    );

    function get_plan_name (
        p_plan_type   in varchar2,
        p_ben_plan_id in number default null
    ) return varchar2;

 --FUNCTION get_calendar_frequency (P_PAY_CYCLE IN VARCHAR2) RETURN NUMBER;

    procedure process_annual_election (
        p_batch_number in number,
        p_user_id      in number
    );

  /* Employer Portal */
    procedure insert_er_benefit_plan (
        p_acc_id               in number,
        p_entrp_id             in number,
        p_effective_date       in varchar2,
        p_plan_type            in varchar2,
        p_fiscal_end_date      in varchar2,
        p_eff_date             in varchar2,
        p_org_eff_date         in varchar2,
        p_plan_start_date      in varchar2,
        p_plan_end_date        in varchar2,
        p_takeover             in varchar2,
        p_user_id              in number,
        p_is_5500              in varchar2 default null,
        p_plan_name            in varchar2 default null,
        p_plan_number          in varchar2 default null,
        p_coll_plan            in varchar2 default null,
        p_plan_fund_code       in varchar2 default null,
        p_plan_benefit_code    in varchar2 default null,
        p_grandfathered        in varchar2 default null,
        p_administered         in varchar2 default null,
        p_clm_lang_in_spd      in varchar2 default null,
        p_subsidy_in_spd_apndx in varchar2 default null,
        p_final_filing_flag    in varchar2 default null,
        p_wrap_plan_5500       in varchar2 default null,
        p_wrap_opt_flg         in varchar2 default '1',   -- Added by Swamy for Development of Erisa Enrollment Ticket#
        p_erissa_erap_doc_type in varchar2, -- added by Joshi for 7791
        x_ben_plan_id          out number,
        x_return_status        out varchar2,
        x_error_message        out varchar2
    );

    procedure change_annual_election (
        p_batch_number  in number,
        p_user_id       in number,
        p_source        in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

     -- Added by swamy for Ticket#5824
    function get_rollover (
        p_acc_id     in number,
        p_plan_type  in varchar2,
        p_start_date in date,
        p_end_date   in date
    ) return number;

-- Added by Joshi for 8634.This is called from MASS_RENEW_ENROLL_EMPLOYEES
-- separate procedure for renewing the employees from EDI process
    procedure add_renew_employees_edi (
        p_acc_id          in number,
        p_annual_election in number,
        p_er_ben_plan_id  in number,
        p_user_id         in number,
        p_cov_tier_name   in varchar2 default null,
        p_effective_date  in date default null,
        p_batch_number    in number,
        x_return_status   out varchar2,
        x_error_message   out varchar2,
        p_status          in varchar2 default 'A',
        p_life_event_code in varchar2 default null
    );

  -- Added by Swamy for DB Upgrade on 17/08/2021
    function get_benefit_codes_info (
        p_entity_id number
    ) return tbl_benefit_codes
        pipelined
        deterministic;

-- Added by Swamy for Ticket#10431(Renewal Resubmit)
    procedure update_ben_plan_enrollment_setup (
        p_ben_plan_id                 in number,
        p_plan_start_date             in date,
        p_plan_end_date               in date,
        p_runout_period_days          in number,
        p_runout_period_term          in varchar2,
        p_funding_options             in varchar2,
        p_rollover                    in varchar2,
        p_new_hire_contrib            in varchar2,
        p_last_update_date            in date,
        p_last_updated_by             in number,
        p_effective_date              in date,
        p_minimum_election            in number,
        p_maximum_election            in number,
        p_grace_period                in number,
        p_batch_number                in number,
        p_non_discrm_flag             in varchar2,
        p_plan_docs_flag              in varchar2,
        p_renewal_flag                in varchar2,
        p_renewal_date                in date,
        p_open_enrollment_start_date  in date,
        p_open_enrollment_end_date    in date,
        p_eob_required                in varchar2,
        p_deduct_tax                  in varchar2,
        p_update_limit_match_irs_flag in varchar2,
        p_pay_acct_fees               in varchar2,
        p_source                      in varchar2,
        p_account_type                in varchar2,
        p_fiscal_end_date             in varchar2,
        p_plan_name                   in varchar2,
        p_plan_number                 in varchar2,
        p_takeover                    in varchar2,-- added by Joshi for 7791
        p_org_eff_date                in varchar2,
        p_plan_type                   in varchar2,
        p_short_plan_yr               in varchar2,
        p_plan_doc_ndt_flag           in varchar2,
        x_return_status               out varchar2,
        x_error_message               out varchar2
    );

end pc_benefit_plans;
/


-- sqlcl_snapshot {"hash":"a42122167b4461ae2a4d42a4a5cebcaac90523eb","type":"PACKAGE_SPEC","name":"PC_BENEFIT_PLANS","schemaName":"SAMQA","sxml":""}