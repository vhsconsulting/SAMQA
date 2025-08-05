create or replace package samqa.pc_employer_enroll is
    type varchar2_tbl is
        table of varchar2(1000) index by binary_integer;  -- Increased the size from 300 to 1000 by swamy for Production issue dated 27/10/2020 by mail Ticket#9550
  -- SLN added for ER health PLAN

-- Added by Joshi for 10431

    type last_enroll_or_renewed_by_row is record (
            enoll_or_renewed_by      varchar2(30),
            enoll_or_renewed_by_desc varchar2(30)
    );
    type er_health_plan_t is record (
            entrp_id       enterprise.entrp_id%type,
            acc_num        account.acc_num%type,
            effective_date varchar2(10),
            carrier_name   enterprise.name%type,
            deductible     employer_health_plans.deductible%type,
            plan_type      lookups.lookup_code%type,
            plan_name      lookups.lookup_name%type,
            carrier_id     employer_health_plans.carrier_id%type,
            health_plan_id employer_health_plans.health_plan_id%type,
            status         employer_health_plans.status%type
    );
    type ret_er_health_plan_t is
        table of er_health_plan_t;
    procedure insert_employer (
        p_name                         in varchar2,
        p_ein_number                   in varchar2,
        p_address                      in varchar2,
        p_city                         in varchar2,
        p_state                        in varchar2,
        p_zip                          in varchar2,
        p_contact_name                 in varchar2,
        p_phone                        in varchar2,
        p_email                        in varchar2,
        p_fee_plan_type                in number,
        p_plan_code                    in number,
        p_broker_lic                   in varchar2,
        p_card_allowed                 in varchar2,
        p_er_contribution_freq         in number,
        p_ee_contribution_freq         in number,
        p_er_contribution_flag         in number,
        p_ee_contribution_flag         in number,
        p_setup_fee_paid_by            in number,
        p_maint_fee_paid_by            in number,
        p_management_account_user_name in varchar2,
        p_enrollment_account_user_name in varchar2,
        p_management_account_password  in varchar2,
        p_enrollment_account_password  in varchar2,
        p_password_question            in varchar2,
        p_password_answer              in varchar2,
        p_lang_perf                    in varchar2,
        p_peo_ein                      in varchar2 default null,
        x_enrollment_id                out number,
        x_error_message                out varchar2,
        x_return_status                out varchar2
    );

    procedure update_employer (
        p_entrp_id            in number,
        p_name                in varchar2,
        p_ein_number          in varchar2 default null,
        p_address             in varchar2,
        p_city                in varchar2,
        p_state               in varchar2,
        p_zip                 in varchar2,
        p_contact_name        in varchar2,
        p_phone               in varchar2,
        p_email               in varchar2,
        p_user_id             in number,
        p_office_phone_number in varchar2 default null,             -- Added by Joshi for 10430
        p_fax_id              in varchar2 default null,              -- Added by Joshi for 10430
        x_error_message       out varchar2,
        x_return_status       out varchar2
    );

    procedure delete_employer (
        p_enrollment_id in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure insert_emp_health_plan (
        p_entrp_id            in number,
        p_carrier_id          in number
      --,p_single_deductible   IN NUMBER
      --,p_family_deductible   IN NUMBER
        ,
        p_plan_type           in number,
        p_deductible          in number,
        p_single_contribution in number,
        p_family_contribution in number,
        p_effective_date      in varchar2,
        x_error_message       out varchar2,
        x_return_status       out varchar2
    );

    procedure bulk_insert_emp_health_plan (
        p_entrp_id       in number,
        p_carrier_id     in varchar2_tbl,
        p_deductible     in varchar2_tbl,
        p_plan_type      in varchar2_tbl,
        p_effective_date in varchar2_tbl,
        x_error_message  out varchar2,
        x_return_status  out varchar2
    );

    procedure update_emp_health_plan (
        p_health_plan_id      in number,
        p_entrp_id            in number,
        p_carrier_id          in number,
        p_plan_type           in number,
        p_deductible          in number,
        p_contribution_amount in number,
        p_user_id             in number,
        x_error_message       out varchar2,
        x_return_status       out varchar2
    );

    procedure delete_emp_health_plan (
        p_entrp_id       in number,
        p_health_plan_id in varchar2_tbl,
        p_user_id        in number,
        x_error_message  out varchar2,
        x_return_status  out varchar2
    );

    procedure insert_emp_health_plan_renew (
        p_entrp_id            in number,
        p_carrier_id          in number
      --sln for new coverage type
      --,p_single_deductible   IN NUMBER
      --,p_family_deductible   IN NUMBER
        ,
        p_plan_type           in number,
        p_deductible          in number,
        p_single_contribution in number,
        p_family_contribution in number,
        p_effective_date      in varchar2,
        p_renewal_date        in varchar2,
        p_user_id             in number,
        x_error_message       out varchar2,
        x_return_status       out varchar2
    );

    procedure create_employer (
        p_name                   in varchar2,
        p_ein_number             in varchar2,
        p_address                in varchar2,
        p_city                   in varchar2,
        p_state                  in varchar2,
        p_zip                    in varchar2,
        p_account_type           in varchar2,
        p_start_date             in varchar2,
        p_phone                  in varchar2,
        p_email                  in varchar2,
        p_fax                    in varchar2,
        p_contact_name           in varchar2,
        p_contact_phone          in varchar2,
        p_broker_id              in number,
        p_salesrep_id            in number,
        p_ga_id                  in number,
        p_plan_code              in number,
        p_card_allowed           in varchar2,
        p_setup_fee              in number,
        p_note                   in varchar2,
        p_pin_mailer             in varchar2,
        p_cust_svc_rep           in number,
        p_allow_eob              in varchar2,
        p_teamster_group         in varchar2,
        p_user_id                in number,
        p_takeover_flag          in varchar2 default null,
        p_total_employees        in number,
        p_maint_fee_flag         in number,
        x_acc_num                out varchar2,
        x_error_message          out varchar2,
        x_return_status          out varchar2,
        p_allow_online_renewal   in varchar2,
        p_allow_election_changes in varchar2
    );

    procedure setup_teamster_group (
        p_entrp_id in number,
        p_name     in varchar2,
        p_user_id  in number
    );

    procedure create_enterprise_relation (
        p_entrp_id      in number,
        p_entity_id     in number,
        p_entity_type   in varchar2,
        p_relat_type    in varchar2,
        p_user_id       in number default 0,
        x_return_status out varchar2,
        x_error_message out varchar2
    );
  --SLN for getting employer_health_plans
    function get_er_health_plan (
        p_entrp_id in number
    ) return ret_er_health_plan_t
        pipelined
        deterministic;

    type employer_ein_row_t is record (
            ein                   number,
            error_message         varchar2(1000),
            error_flag            varchar2(2),
            active_sa_user_exists varchar2(1)
    );  -- 10430 Joshi

    type employer_ein_record_t is
        table of employer_ein_row_t;
    function validate_ein (
        p_ein in varchar2
    ) return employer_ein_record_t
        pipelined
        deterministic;

    type user_row_t is record (
            user_name     varchar2(100),
            password      varchar2(100),
            email_address varchar2(250),
            error_message varchar2(1000),
            error_flag    varchar2(2)
    );
    type user_record_t is
        table of user_row_t;
    type cobra_row_t is record (
            rate_plan_id        number,
            rate_plan_detail_id number,
            rate_plan_name      varchar2(1000),
            min_range           varchar2(2000),   --- 3933 rprabu 02/07/2019
            max_range           varchar2(2000),   --- 3933 rprabu 02/07/2019
            range               varchar2(2000),
            fee                 number,
            error_message       varchar2(1000),
            error_flag          varchar2(2)
    );
    type cobra_record_t is
        table of cobra_row_t;
    function get_cobra_srvc (
        p_covg_type in varchar2
    ) return cobra_record_t
        pipelined
        deterministic;

    function validate_user (
        p_user_name  in varchar2,
        p_password   in varchar2,
        p_email_addr in varchar2,
        p_tax_id     in varchar2
    ) return user_record_t
        pipelined
        deterministic;

    procedure insert_employer_online (
        p_name                         in varchar2,
        p_ein_number                   in varchar2,
        p_address                      in varchar2,
        p_city                         in varchar2,
        p_state                        in varchar2,
        p_zip                          in varchar2,
        p_contact_name                 in varchar2,
        p_phone                        in varchar2,
        p_fax_id                       in varchar2,
        p_email                        in varchar2,
        p_card_allowed                 in varchar2,
        p_management_account_user_name in varchar2,
        p_management_account_password  in varchar2,
        p_password_question            in varchar2,
        p_password_answer              in varchar2,
        p_account_type                 in varchar2,
        p_office_phone_no              in varchar2, /* 7857 Joshi% */
        p_referral_url                 in varchar2 default null, /* 9049 Jagadeesh% */
        p_referral_code                in varchar2 default null, /* 9049 Jagadeesh% */
        p_enrolled_by                  in number default null,     ----9141 added by rprabu on 30/07/2020
        p_enrolle_type                 in varchar2 default 'E',    ----9141 added by rprabu on 30/07/2020
        p_industry_type                in varchar2,                 ----9141 added by rprabu on 30/07/2020
        p_user_id                      in number, ---Ticket 9392 rprabu
        p_salesrep_flag                in varchar2, /*Ticket#11509*/
        p_salesrep_name                in varchar2, /*Ticket#11509*/
        p_salesrep_id                  in number,                --- Added by Jaggi #11629
        x_enrollment_id                out number,
        x_error_message                out varchar2,
        x_return_status                out varchar2
    );

    procedure create_employer_staging (
        p_name                         in varchar2,
        p_ein_number                   in varchar2,
        p_address                      in varchar2,
        p_city                         in varchar2,
        p_state                        in varchar2,
        p_zip                          in varchar2,
        p_contact_name                 in varchar2,
        p_phone                        in varchar2,
        p_fax_id                       in varchar2,
        p_email                        in varchar2,
        p_card_allowed                 in varchar2,
        p_management_account_user_name in varchar2,
        p_management_account_password  in varchar2,
        p_password_question            in varchar2,
        p_password_answer              in varchar2,
        p_account_type                 in varchar2,
        p_batch_number                 in varchar2, /*Ticket#7016 */
        p_office_phone_no              in varchar2, /*Ticket#7857  */
        p_salesrep_flag                in varchar2, /*Ticket#11509*/
        p_salesrep_name                in varchar2, /*Ticket#11509*/
        x_enrollment_id                out number,
        x_error_message                out varchar2,
        x_return_status                out varchar2
    );

    procedure create_stacked_acct (
        p_ein_number     in varchar2,
        x_return_status  out varchar2,
        x_return_message out varchar2
    );

    function validate_compliance_acct (
        p_ein in varchar2
    ) return varchar2;

    function get_company_name (
        p_ein_number in varchar2
    ) return varchar2;
  /* Ticket#5862 */
    procedure update_pop_info (
        p_entrp_id       in number,
        p_batch_number   in number,
        p_user_id        in number,
        p_source         in varchar2 default null, --Ticket#5020
        p_new_ben_pln_id in out varchar2,  -- Added by Jaggi for Ticket#10431(Renewal Resubmit)
        x_er_ben_plan_id out number,
        x_error_status   out varchar2,
        x_error_message  out varchar2
    );
  /*Ticket#5862 */
    procedure insert_custom_eligib_req (
        p_min_age_req                                in varchar2,
        p_min_age                                    in varchar2,
        p_min_service_req                            in varchar2,
        p_no_of_hrs_current                          in varchar2,
        p_new_ee_month_servc                         in varchar2,
        p_plan_new_ee_join                           in varchar2,
        p_collective_bargain_flag                    in varchar2,
        p_union_ee_join_flag                         in varchar2,
        p_ee_exclude_plan_flag                       in varchar2,
        p_no_of_hrs_part_time                        in varchar2,
        p_exclude_seasonal_flag                      in varchar2,
        p_fmla_leave                                 in varchar2,
        p_fmla_tax                                   in varchar2,
        p_fmla_under_cobra                           in varchar2,
        p_fmla_return_leave                          in varchar2,
        p_fmla_contribution                          in varchar2,
        p_cease_covg_flag                            in varchar2,
        permit_partcp_eoy                            in varchar2,
        p_ee_rehire_plan                             in varchar2,
        p_ee_reemploy_plan                           in varchar2,
        p_automatic_enroll                           in varchar2,
        p_er_partcp_elect                            in varchar2,
        p_failure_plan_yr                            in varchar2,
        p_plan_admin                                 in varchar2,
        p_admin_contact_type                         in varchar2,
        p_admin_name                                 in varchar2,
        p_hsa_contrib                                in varchar2,
        p_max_contrib_amt                            in varchar2,
        p_matching_contrib                           in varchar2,
        p_non_elect_contrib                          in varchar2,
        p_percent_non_elect_amt                      in varchar2,
        p_other_non_elect_amt                        in varchar2,
        p_max_contrib_hsa                            in varchar2,
        p_other_max_contrib                          in varchar2,
        p_flex_credit_flag                           in varchar2,
        p_flex_credit_cash                           in varchar2,
        p_flex_cash_amt                              in varchar2,
        p_er_contrib_flex                            in varchar2,
        p_flex_contrib_amt                           in varchar2,
        p_other_flex_amt                             in varchar2,
        p_cash_out_amt                               in varchar2,
        p_max_flex_cash_out                          in varchar2,
        p_dollar_amt                                 in varchar2,
        p_other_max_cash_out                         in varchar2,
        p_amt_distrib                                in varchar2,
        p_min_contrib_hsa                            in varchar2,
        p_when_partcp_eoy                            in varchar2,
      /* Ticket#5020 */
        p_source                                     in varchar2,
        p_page_validity                              in varchar2,
        p_batch_number                               in number,
        p_entity_id                                  in number,
        p_user_id                                    in number,
        p_fmla_flag                                  in varchar2,--- Added by rprabu Ticket #7832
        p_flex_credit_5000a_flag                     in varchar2,--- Added by rprabu Ticket #7832
        p_flex_credits_er_contrib                    in varchar2,--- Added by rprabu Ticket #7832
        p_employee_elections                         in varchar2,               -- Start Added for Ticket#11037 by Swamy
        p_include_participant_election               in varchar2,
        p_change_status_below_30                     in varchar2,
        p_change_status_special_annual_enrollment    in varchar2,
        p_include_fmla_lang                          in varchar2,                 -- End of addition for Ticket#11037 by Swamy
        p_change_status_dependent_special_enrollment in varchar2,  -- Added by Swamy for Ticket#12131 14052024
        x_error_status                               out varchar2,
        x_error_message                              out varchar2
    );

    procedure update_plan_info (
        p_entrp_id             in number,
        p_fiscal_end_date      in varchar2,
        p_plan_type            in varchar2,
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
        p_short_plan_yr        in varchar2 default null,
        p_wrap_opt_flg         in varchar2 default '1', -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
        p_erissa_erap_doc_type in varchar2 default null, -- Added by Joshi for 7791.
        x_er_ben_plan_id       out number,
        x_error_status         out varchar2,
        x_error_message        out varchar2
    );

    procedure insert_pop_eligib_req (
        p_entity_id       in number,
        p_user_id         in number,
        p_benefit_code_id in varchar2_tbl,
        p_entity_name     in varchar2_tbl,
        p_batch_number    in number
    );

    type get_ga_row is record (
            ga_name       varchar2(100),
            ga_id         varchar2(10),
            error_message varchar2(1000),
            error_status  varchar2(100)
    );
    type get_ga_row_t is
        table of get_ga_row;
    type get_salesrep_row is record (
            salesrep_name varchar2(100),
            salesrep_id   varchar2(10),
            error_message varchar2(1000),
            error_status  varchar2(100)
    );
    type get_salesrep_row_t is
        table of get_salesrep_row;
    type get_contact_type_row is record (
            contact_type  varchar2(1000),
            contact_code  varchar2(100),
            error_message varchar2(1000),
            error_status  varchar2(100)
    );
    type get_pop_eligibility_row is record (
            lookup_code   varchar2(100),
            description   varchar2(1000),
            error_message varchar2(1000),
            error_status  varchar2(100)
    );
    type get_cobra_plan_type_row is record (
            lookup_code   varchar2(100),
            description   varchar2(1000),
            error_message varchar2(1000),
            error_status  varchar2(100)
    );
    type get_report_type_row is record (
            lookup_code   varchar2(100),
            description   varchar2(1000),
            error_message varchar2(1000),
            error_status  varchar2(100)
    );
    type get_pop_eligibility_row_t is
        table of get_pop_eligibility_row;
    type get_report_type_row_t is
        table of get_report_type_row;
    type get_cobra_plan_type_row_t is
        table of get_cobra_plan_type_row;
    type get_contact_type_row_t is
        table of get_contact_type_row;
    function get_contact_type return get_contact_type_row_t
        pipelined
        deterministic;

    function get_ga_data return get_ga_row_t
        pipelined
        deterministic;

    function get_salesrep return get_salesrep_row_t
        pipelined
        deterministic;

    function get_pop_eligibility return get_pop_eligibility_row_t
        pipelined
        deterministic;

    function get_pop_pricing (
        p_rate_plan_name in varchar2,
        p_account_type   in varchar2
    ) return number;

    function get_report_type return get_report_type_row_t
        pipelined
        deterministic;

    function get_plan_fund_code return get_report_type_row_t
        pipelined
        deterministic;

    function get_benefit_codes return get_report_type_row_t
        pipelined
        deterministic;

    function get_cobra_plan_type return get_cobra_plan_type_row_t
        pipelined
        deterministic;
    /*
  PROCEDURE create_cobra_plan(p_entrp_id IN NUMBER ,
  p_Plan_name IN VARCHAR2,
  p_insurance_company_name IN  VARCHAR2,
  p_governing_state IN VARCHAR2,
  p_plan_start_date IN VARCHAR2,
  p_plan_end_date IN VARCHAR2,
  p_plan_type IN VARCHAR2,
  p_description IN VARCHAR2,
  p_self_funded_flag IN vARCHAR2,
  p_conversion_flag  IN VARCHAR2,
  p_bill_cobra_premium_flag IN VARCHAR2,
  p_coverage_terminate IN VARCHAR2,
  p_age_rated_flag  IN VARCHAR2,
  p_carrier_contact_name IN VARCHAR2,
  p_Policy_number IN VARCHAR2,
  p_plan_number IN VARCHAR2,
  p_carrier_contact_email IN VARCHAR2,
  p_carrier_phone_no IN VARCHAR2,
  p_carrier_addr  IN VARCHAR2,
  p_ee_premium  IN VARCHAR2,
  p_ee_spouse_premium  IN VARCHAR2,
  p_ee_child_premium  IN VARCHAR2,
  p_ee_children_premium IN VARCHAR2,
  p_ee_family_premium IN VARCHAR2,
  p_spouse_premium    IN VARCHAR2,
  p_child_premium  IN VARCHAR2,
  p_spouse_child_premium IN VARCHAR2,
  p_eff_date IN VARCHAR2,
  p_user_id IN NUMBER,
  p_salesrep_flag IN VARCHAR2,
  p_salesrep_id IN VARCHAR2,
  p_rate_plan_id IN VARCHAR2_TBL ,
  p_rate_plan_detail_id IN VARCHAR2_TBL ,
  p_list_price  IN VARCHAR2_TBL ,
  p_tot_price IN NUMBER DEFAULT NULL,
  p_payment_method IN VARCHAR2 DEFAULT NULL,
  x_er_ben_plan_id OUT NUMBER,
  x_error_status OUT VARCHAR2,
  x_error_message OUT VARCHAR2);
  */
    procedure create_hsa_plan_old (
        p_entrp_id           in number,
        p_peo_ein            in number,
        p_plan_code          in number,
        p_mon_fees_paid_by   in varchar2, --If yes then 2 else 1
        p_ann_fees_paid_by   in varchar2, --If yes then 3 else 1
        p_debit_card_allowed in varchar2, --allowed is 1 else 0
        p_salesrep_id        in number,
        p_user_id            in number,
        p_subscribe_to_acn   in varchar2,   -- Added by Swamy for Ticket#6794(ACN Migration)
        x_error_status       out varchar2,
        x_error_message      out varchar2
    );

    procedure update_contact_info (
        p_contact_id      number default null,
        p_entrp_id        number,
        p_first_name      varchar2,
        p_email           varchar2,
        p_account_type    varchar2,
        p_contact_type    varchar2,
        p_user_id         varchar2,
        p_ref_entity_id   varchar2,
        p_ref_entity_type varchar2,
        p_send_invoice    varchar2,
        p_status          varchar2,
        p_phone_num       varchar2 default null,
        p_fax_no          varchar2 default null,
        p_job_title       varchar2 default null,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    );

    procedure create_erisa_plan (
        p_entrp_id             in number,
        p_state_of_org         in varchar2,
        p_entity_type          in varchar2,
        p_entity_name          in varchar2,
        p_fiscal_end_date      in varchar2,
        p_aff_name             in varchar2_tbl,
        p_cntrl_grp            in varchar2_tbl,
        p_plan_name            in varchar2,
        p_plan_number          in varchar2,
        p_eff_date             in varchar2,
        p_org_eff_date         in varchar2,
        p_plan_start_date      in varchar2,
        p_plan_end_date        in varchar2,
        p_user_id              in number,
        p_no_of_ee             in number,
        p_no_of_elg_ee         in number,
        p_benefit_code_name    in varchar2_tbl,
        p_description          in varchar2_tbl,
        p_5500_filing          in varchar2,
        p_grandfathered        in varchar2,
        p_administered         in varchar2,
        p_clm_lang_in_spd      in varchar2,
        p_subsidy_in_spd_apndx in varchar2,
        p_takeover             in varchar2,
        p_plan_fund_code       in varchar2,
        p_plan_benefit_code    in varchar2,
        p_tot_price            in number,
        p_rate_plan_id         in varchar2_tbl,
        p_rate_plan_detail_id  in varchar2_tbl,
        p_list_price           in varchar2_tbl,
        p_payment_method       in varchar2,
        p_final_filing_flag    in varchar2,
        p_wrap_plan_5500       in varchar2,
        p_salesrep_id          in number,
        p_wrap_opt_flg         in varchar2, -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
        p_erissa_erap_doc_type in varchar2, -- added By Joshi for 7791,
        x_er_ben_plan_id       out number,
        x_error_status         out varchar2,
        x_error_message        out varchar2
    );

    procedure insert_benefit_codes (
        p_entity_id     in varchar2 --er_ben_plan_id
        ,
        p_entity_type   in varchar2 --FORM_5500_ONLINE_ENROLLMENT
        ,
        p_code_name     in varchar2_tbl,
        p_description   in varchar2_tbl,
        p_er_contrib    in number default null,
        p_ee_contrib    in number default null,
        p_eligibility   in varchar2 default null,
        p_user_id       in number default null,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure create_salesrep (
        p_entrp_id      in number,
        p_salesrep_id   in number,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

    procedure create_aca_eligibility (
        p_ben_plan_id                 in number,
        p_aca_ale_flag                in varchar2,
        p_variable_hour_flag          in varchar2,
        p_intl_msrmnt_period          in number,
        p_intl_msrmnt_start_date      in varchar2,
        p_intl_admn_period            in varchar2, -- Replaced Number with Varchar2 by Swamy Erisa Ticket#6294 ,
        p_stblty_period               in number,
        p_msrmnt_start_date           in varchar2,
        p_msrmnt_period               in number,
        p_msrmnt_end_date             in varchar2,
        p_admn_start_date             in varchar2,
        p_admn_period                 in number,
        p_admn_end_date               in varchar2,
        p_stblt_start_date            in varchar2,
        p_stblt_period                in number,
        p_stblt_end_date              in varchar2,
        p_irs_lbm_flag                in varchar2,
        p_mnthl_msrmnt_flag           in varchar2,
        p_same_prd_bnft_start_date    in varchar2,
        p_new_prd_bnft_start_date     in varchar2,
        p_user_id                     in number,
        p_eligibility                 in varchar2_tbl,
        p_er_contrib                  in varchar2_tbl,
        p_ee_contrib                  in varchar2_tbl,
        p_benefit_code_id             in varchar2_tbl,
        p_entrp_id                    in number,
        p_collective_bargain_flag     in varchar2 default 'N', -- Start Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
        p_intl_msrmnt_period_det      in varchar2 default null,
        p_fte_same_period_resume_date in varchar2 default 'N',
        p_fte_diff_period_resume_date in varchar2 default null,
        p_fte_hrs                     in varchar2 default null,
        p_fte_salary_msmrt_period     in varchar2 default null,
        p_fte_hourly_msmrt_period     in varchar2 default null,
        p_fte_other_msmrt_period      in varchar2 default null,
        p_fte_other_ee_detail         in varchar2 default null,
        p_fte_look_back               in varchar2 default null,
        p_fte_lkp_salary_msmrt_period in varchar2 default null,
        p_fte_lkp_hourly_msmrt_period in varchar2 default null,
        p_fte_lkp_other_msmrt_period  in varchar2 default null,
        p_fte_lkp_other_ee_detail     in varchar2 default null,
        p_fte_same_period_select      in varchar2 default null,
        p_fte_diff_period_select      in varchar2 default null,
        p_define_intl_msrmnt_period   in varchar2 default null, -- End By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
        x_error_status                out varchar2,
        x_error_message               out varchar2
    );

    procedure decline_enrollment (
        p_acc_id        in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

    procedure cr_existing_user_login (
        p_tax_id        in varchar2,
        p_account_type  in varchar2,
        p_user_id       in number, -----9392 rprabu 21/10/2020
        x_entrp_id      out number,
        x_error_message out varchar2,
        x_error_status  out varchar2
    );

    procedure upsert_er_info (
        p_entrp_id                    in number,
        p_name                        in varchar2,
        p_state_of_org                in varchar2,
        p_fiscal_yr_end               in varchar2,
        p_affiliate_employers_flag    varchar2, --- added by   rprabu on 09/10/2018 for the ticket 6732.
        p_controlled_group_flag       varchar2, --- added by   rprabu on 09/10/2018 for the ticket 6732.
        p_type_entity                 in varchar2,
        p_entity_name                 in varchar2,
        p_represent_name              in varchar2,
        p_affliate_name               in varchar2_tbl,
        p_contrl_grp_name             in varchar2_tbl,
        p_total_ees                   in varchar2,
        p_toal_fsa_ees                in varchar2,
        p_comp_sponsored_medical_plan in varchar2,
        p_include_fsa_ees             in varchar2,
        p_batch_number                in number,
        p_user_id                     in number,
        x_enrollment_id               out number,
        x_error_status                out varchar2,
        x_error_message               out varchar2
    );
  ---------------   Ticket #6928 The Benefit plans selected by pressing Confirm Plan selection(s) is not displaying in Summary page.

    function get_er_plan_info (
        p_entrp_id     in number,
        p_batch_number in number
    ) return get_report_type_row_t
        pipelined
        deterministic;
  ---------------   Ticket #6928 The Benefit plans selected by pressing Confirm Plan selection(s) is not displaying in Summary page.
  ---------------   UPSERT_ER_PLAN_INFO Added by rprabu on 05/11/2018

    procedure upsert_er_plan_info (
        p_entrp_id      in number,
        p_batch_number  in number,
        p_plan_types    in varchar2_tbl,
        p_source        in varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

    function get_fsa_plan_type return get_report_type_row_t
        pipelined
        deterministic;

    procedure upsert_plan_info (
        p_enrollment_id               in number,
        p_plan_type                   in varchar2,
        p_entrp_id                    in number,
        p_user_id                     in number,
        p_batch_number                in number,
        p_plan_number                 in number default null,
        p_plan_start_date             in varchar2,
        p_plan_end_date               in varchar2,
        p_eff_date                    in varchar2 default null,
        p_org_eff_date                in varchar2 default null,
        p_open_enrollment_flag        in varchar2, ---ticket 7225 added by rprabu on 16/11/2018
        p_grace_period_flag           in varchar2, ---ticket 7225 added by rprabu on 16/11/2018
        p_open_enrollment_date        in varchar2,
        p_open_enrollment_end_date    in varchar2,
        p_min_election                in varchar2,
        p_max_annual_election         in varchar2,
        p_run_out_period              in varchar2,
        p_ee_pay_per_period           in varchar2 default null,
        p_allow_debit_card            in varchar2 default null,
        p_pay_day                     in varchar2 default null,
        p_take_over                   in varchar2 default null,
        p_rollover_flag               in varchar2 default null,
        p_rollover_amount             in number default null,
        p_grace_period                in varchar2 default null,
        p_er_contrib_flag             in varchar2 default null,
        p_er_contrib_method           in varchar2 default null,
        p_er_amount                   in varchar2 default null,
        p_heart_act                   in varchar2 default null,
        p_amt_reservist_disrib        in varchar2 default null,
        p_plan_with_hsa               in varchar2 default null,
        p_plan_with_hra               in varchar2 default null,
        p_highway_flag                in varchar2 default null,
        p_transit_pass_flag           in varchar2 default null,
        p_run_out_term                in varchar2 default null,
        p_short_plan_yr_flag          in varchar2 default null,
        p_post_deductible_plan        in varchar2 default null,
        p_plan_docs_flag              in varchar2 default null,
        p_ndt_testing                 in varchar2 default null,
        p_new_plan_yr                 in varchar2 default null,
        p_org_ben_plan_id             in varchar2 default null,
        p_new_hire                    in varchar2 default null,
        p_eob                         in varchar2 default null,
        p_payroll_frequency           in varchar2_tbl,
        p_no_of_periods               in varchar2_tbl,
        p_pay_date                    in varchar2_tbl,
        p_funding_option              in varchar2 default null,---8313 04/11/2019 rprabu
        p_update_limit_match_irs_flag in varchar2 default null,---8237 12/11/2019 rprabu
        p_page_validity               in varchar2, --- RPRABU 27/07/2018 ticket 6346
        p_renewal_new_plan            in varchar2,    -- Added by Swamy for Ticket#9601 09/11/2021
        x_enrollment_detail_id        out number,
        x_error_status                out varchar2,
        x_error_message               out varchar2
    );

  -- 6346 ticket rprabu 01/08/2018
    type fsa_plan_info_t is record (
            plan_type     fsa_hra_plan_type.lookup_code%type,
            plan_status   varchar2(1),
            error_status  varchar2(10),
            error_message varchar2(500)
    );
  -- 6346 ticket rprabu 01/08/2018
    type ret_fsa_plan_info_t is
        table of fsa_plan_info_t;
  -- Below function added by rprabu function to get FSA plan statuses ticket 6346
    function get_fsa_plan_info (
        p_batch_number in number,
        p_entrp_id     in number
    ) return ret_fsa_plan_info_t
        pipelined
        deterministic;
  -- Below Type added by rprabu function to get MULTI BANK FUNCTIONALITY ticket 6346
    type tbl_user_bank_acct_staging is
        table of user_bank_acct_staging%rowtype;
  -- Below function added by rprabu function to get MULTI BANK FUNCTIONALITY ticket 6346
    function get_user_bank_acct_staging (
        p_batch_number          in number,
        p_entrp_id              in number,
        p_user_bank_acct_stg_id in number,
        p_account_type          in varchar2,
        p_annual_optional_remit in varchar2   -- Added by Swamy for Ticket#12534
--      p_user_id               IN NUMBER      -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
    ) return tbl_user_bank_acct_staging
        pipelined;

  -- Below PROCEDURE added by rprabu function to get MULTI BANK FUNCTIONALITY ticket 6346
    procedure upsert_bank_info (
        p_user_bank_acct_stg_id in number,
        p_entrp_id              in number,
        p_batch_number          in number,
        p_account_type          in varchar2,
        p_acct_usage            in varchar2,
        p_display_name          in varchar2,
        p_bank_acct_type        in varchar2,
        p_bank_routing_num      in varchar2,    --Changed from number to varchar2 by Swamy for Production issue (Bank account no and routing no leading zero is not saving. Date 22/04/2022)
        p_bank_acct_num         in varchar2,     --Changed from number to varchar2 by Swamy for Production issue (Bank account no and routing no leading zero is not saving. Date 22/04/2022)
        p_bank_name             in varchar2,
        p_user_id               in number,
        p_validity              in varchar2,
        p_bank_authorize        in varchar2,          -- added by jaggi ##9602
        p_giac_response         in varchar2,   -- Added by Swamy for Ticket#12309 
        p_giac_verify           in varchar2,   -- Added by Swamy for Ticket#12309 
        p_giac_authenticate     in varchar2,   -- Added by Swamy for Ticket#12309 
        p_bank_acct_verified    in varchar2,   -- Added by Swamy for Ticket#12309 
        p_business_name         in varchar2,   -- Added by Swamy for Ticket#12309 
        p_annual_optional_remit in varchar2,   -- Added by Swamy for Ticket#12534 
        p_existing_bank_flag    in varchar2,   -- Added by Swamy for Ticket#12534
        p_bank_acct_id          in number,     -- Added by Swamy for Ticket#12534(12624)
        x_user_bank_acct_stg_id out number,
        x_bank_status           out varchar2,    -- Added by Swamy for Ticket#12534 
        x_error_status          out varchar2,
        x_error_message         out varchar2
    );

  ----Delete_bank_info added by rprabu on 08/10/2018  Ticket 6346
  --- if P_User_Bank_acct_stg_Id is null , then it will delete all the bank records related to the employer.
    procedure delete_bank_info (
        p_user_bank_acct_stg_id in number,
        p_entrp_id              in number,
        p_batch_number          in number,
        p_account_type          in varchar2,
        p_acct_usage            in varchar2, -- Added by Jaggi #11263
        x_error_status          out varchar2,
        x_error_message         out varchar2
    );

    procedure upsert_contact_info (
        p_entrp_id        in number,
        p_contact_id      in number,
        p_first_name      in varchar2,
        p_email           in varchar2,
        p_account_type    in varchar2,
        p_contact_type    in varchar2,
        p_user_id         in varchar2,
        p_ref_entity_id   in varchar2,
        p_ref_entity_type in varchar2,
        p_status          in varchar2,
        p_phone_num       in varchar2,
        p_fax_num         in varchar2,
        p_title           in varchar2,
        p_batch_num       in number,
        p_lic_number      in varchar2 default null, --Ticket#5020
      --Ticket#5469
        p_send_invoice    in number default null,
        p_page_validity   in varchar2 default null,
        p_contact_flg     in varchar2 default 'Y',   -- Added by swamy for Ticket#8684 on 19/05/2020
        p_lic_number_flag in varchar2 default null,   -- Added by swamy for Ticket#9162(Dev ref#8684)
        p_source          in varchar2 default null,    -- Added by Swamy for Ticket#9324 on 16/07/2020
        x_contact_id      out number,
        x_error_status    out varchar2,
        x_error_message   out varchar2
    );

  /*  --- Commented  by rprabu on 22/08/2018 for 6346
  PROCEDURE UPDATE_ELIGIBILE_ADMIN_OPTION
  (
  p_entrp_id          IN NUMBER,
  p_ndt_preference    IN VARCHAR2,
  p_batch_number      IN NUMBER,
  p_er_pretax_flag    IN VARCHAR2,
  p_PERMIT_CASH_FLAG  IN VARCHAR2,
  p_limit_cash_flag   IN VARCHAR2 ,
  p_REVOKE_ELECT_FLAG IN VARCHAR2,
  p_CEASE_COVG_FLAG   IN VARCHAR2,
  p_COLLECTIVE_BARGAIN_FLAG IN VARCHAR2,
  p_NO_OF_HRS_PART_TIME   IN VARCHAR2 ,
  p_NO_OF_HRS_SEASONAL      IN VARCHAR2 ,
  p_NO_OF_HRS_CURRENT      IN VARCHAR2,
  p_NEW_EE_MONTH_SERVC     IN VARCHAR2,
  p_SELECT_ENTRY_DATE_FLAG     IN VARCHAR2,
  p_MIN_AGE_REQ             IN VARCHAR2 ,
  p_PLAN_NEW_EE_JOIN         IN VARCHAR2 ,
  p_AUTOMATIC_ENROLL        IN VARCHAR2,
  p_carrier_flag            IN VARCHAR2,
  p_PERMIT_PARTCP_EOY          IN VARCHAR2,
  P_EE_EXCLUDE_PLAN_FLAG     IN VARCHAR2,
  p_limit_cash_paid         IN VARCHAR2,
  p_coincident_next_flag    IN VARCHAR2,
  p_ndt_testing_flag        IN VARCHAR2,
  p_enrollment_option       IN VARCHAR2,
  P_user_id                 IN NUMBER,
  p_benefit_code            IN VARCHAR2_TBL,
  p_benefit_name            IN VARCHAR2_TBL,
  x_error_status             OUT VARCHAR2,
  x_error_message              OUT VARCHAR2
  );
  */
  --- added by rprabu on 22/08/2018 for 6346
    procedure update_eligibile_admin_option1 (
        p_entrp_id          in number,
        p_batch_number      in number,
        p_er_pretax_flag    in varchar2,
        p_permit_cash_flag  in varchar2,
        p_limit_cash_flag   in varchar2,
        p_revoke_elect_flag in varchar2,
        p_cease_covg_flag   in varchar2,
        p_limit_cash_paid   in varchar2,
        p_user_id           in number,
        p_benefit_code      in varchar2_tbl,
        p_benefit_name      in varchar2_tbl,
        x_error_status      out varchar2,
        x_error_message     out varchar2
    );
  --- added by rprabu on 22/08/2018 for 6346
    procedure update_eligibile_admin_option2 (
        p_entrp_id                in number,
        p_batch_number            in number,
        p_collective_bargain_flag in varchar2,
        p_no_of_hrs_part_time     in varchar2,
        p_no_of_hrs_seasonal      in varchar2,
        p_no_of_hrs_current       in varchar2,
        p_new_ee_month_servc      in varchar2,
        p_select_entry_date_flag  in varchar2,
        p_min_age_req             in varchar2,
        p_plan_new_ee_join        in varchar2,
        p_automatic_enroll        in varchar2,
        p_permit_partcp_eoy       in varchar2,
        p_ee_exclude_plan_flag    in varchar2,
        p_coincident_next_flag    in varchar2,
        x_error_status            out varchar2,
        x_error_message           out varchar2
    );
  --- added by rprabu on 22/08/2018 for 6346
    procedure update_eligibile_admin_option3 (
        p_entrp_id                in number,
        p_batch_number            in number,
        p_ndt_preference          in varchar2,
        p_carrier_flag            in varchar2,
        p_ndt_testing_flag        in varchar2,
        p_enrollment_option       in varchar2,
        p_additional_service_flag in varchar2, --- added by 7680 added by rprabu 16/05/2019
        x_error_status            out varchar2,
        x_error_message           out varchar2
    );

    procedure delete_plan (
        p_batch_number  in varchar2,
        p_plan_type     in varchar2,
        p_entrp_id      in number,
      --Ticket#5469
        p_plan_id       in varchar2 default null,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

    procedure delete_contact (
        p_batch_number  in varchar2,
        p_contact_id    in varchar2,
        p_entrp_id      in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );
  /*Ticket#5469.COBRA Reconstruction */
    procedure generate_batch_number (
        p_entrp_id     in number,
        p_account_type in varchar2,
        p_source       in varchar2 default null, --Ticket#5020
        x_batch_number out number
    );

    procedure update_invoice_bank_info (
        p_batch_number               in varchar2,
        p_entrp_id                   in number,
        p_salesrep_flag              in varchar2,     -- Ticket #6882
        p_salesrep_id                in number,
        p_pay_acct_fees              in varchar2,
        p_invoice_flag               in varchar2,
        p_funding_option             in varchar2,
        p_bank_name                  in varchar2,
        p_account_type               in varchar2,
        p_routing_num                in varchar2,
        p_account_num                in varchar2,
        p_acct_usage                 in varchar2,
        p_payment_method             in varchar2,
        p_bank_authorize             in varchar2,    -- Added by Jaggi ##9602
        p_pay_monthly_fees_by        in varchar2,    -- Added by Jaggi #11263
        p_monthly_fee_payment_method in varchar2,    -- Added by Jaggi #11263
        p_funding_payment_method     in varchar2,    -- Added by Jaggi #11263
        x_error_status               out varchar2,
        x_error_message              out varchar2
    );

    procedure process_fsa_enrollment_renewal (
        p_batch_number       in number,
        p_entrp_id           in number,
        p_user_id            in number
      --Added Renewal parameters
        ,
        p_broker_name        in varchar2 default null,
        p_broker_license_num in varchar2 default null,
        p_broker_contact     in varchar2_tbl,
        p_broker_contact_id  in varchar2_tbl,
        p_broker_email       in varchar2_tbl,
        p_ga_name            in varchar2 default null,
        p_ga_license_num     in varchar2 default null,
        p_ga_contact         in varchar2_tbl,
        p_ga_contact_id      in varchar2_tbl,
        p_ga_email           in varchar2_tbl,
        p_send_invoice       in varchar2 default null,
        p_bank_acct_id       out number,                  -- Added by Swamy for Ticket#12309
        x_error_status       out varchar2,
        x_error_message      out varchar2
    );

    procedure upsert_expense_info (
        p_entrp_id         in number,
        p_user_id          in number,
        p_batch_number     in number,
        p_plan_code        in number,
        p_plan_type        in varchar2_tbl,
        p_basic_expense_id in varchar2_tbl,
        p_comp_expense_id  in varchar2_tbl,
        p_lph_expense_id   in varchar2_tbl,
        x_error_status     out varchar2,
        x_error_message    out varchar2
    );

    procedure upsert_hra_plan_info (
        p_enrollment_id               in number,
        p_entrp_id                    in number,
        p_user_id                     in number,
        p_batch_number                in number,
        p_plan_number                 in number,
        p_take_over                   in varchar2, --Take over --N else Y
        p_short_plan_year_flag        in varchar2,  -- for the Ticket #7187 added by rprabu on 22/11/2018
        p_plan_start_date             in varchar2,
        p_plan_end_date               in varchar2,
        p_eff_date                    in varchar2,
        p_org_eff_date                in varchar2,
        p_open_enrollment_period_flag varchar2, -- for the Ticket #7187 added by rprabu on 12/11/2018
        p_open_enrollment_date        in varchar2,
        p_open_enrollment_end_date    in varchar2,
        p_rollover_flag               in varchar2,
        p_rollover_method             in varchar2, --  Ticket #7088  added by rprabu 23/10/2018
        p_rollover_amount             in number,
        p_run_out_period              in varchar2,
        p_allow_debit_card            in varchar2,
        p_plan_docs_flag              in varchar2,
        p_plan_with_fsa               in varchar2,--New
        p_run_out_term                in varchar2,
        p_new_hire_contrib            in varchar2,
        p_er_reimburse_claim          in varchar2,
        p_wish_to_cover               in varchar2,
        p_ee_percent_share            in varchar2, ---- rprabu 09/11/2018 ticket 6346
        p_er_percent_share            in varchar2,
        p_individual_plan_flag        in varchar2,
        p_hra_covg_plan_level         in varchar2,
        p_single_ee_contrib_amt       in varchar2,
        p_ee_spouse_ee_amt            in varchar2,
        p_ee_spouse_amt               in varchar2,
        p_ee_children_amt             in varchar2,
        p_ee_childen_depend_amt       in varchar2,
        p_family_ee_amt               in varchar2,
        p_family_spouse_amt           in varchar2,
        p_family_children_amt         in varchar2,
        p_coverage_tier               in varchar2,
        p_enrollment_detail_id        in number,
        p_org_ben_plan_id             in varchar2 default null,
        p_new_plan_yr                 in varchar2 default null,
        p_eob                         in varchar2 default null,
        p_source                      in varchar2 default null,
        p_plan_type                   in varchar2 default null,
        p_covg_tier                   in varchar2_tbl,
        p_funding_amount              in varchar2_tbl,
        p_covg_tier2                  in varchar2_tbl,
        p_funding_amount2             in varchar2_tbl,
        p_max_rollover_amount         in varchar2_tbl,
        p_ndt_testing                 in varchar2 default null,   -- Added by Swamy For Ticket#4805
        p_agree_debit_card            in varchar2, --- 7889 rprabu
        p_funding_option              in varchar2,  ---- 8313  rprabu 04/11/2019
        x_enrollment_detail_id        out number,
        x_error_status                out varchar2,
        x_error_message               out varchar2
    );
  /*
  PROCEDURE UPDATE_HRA_ADMIN_OPTION(
  p_entrp_id                IN NUMBER,
  p_ndt_preference          IN VARCHAR2,
  p_batch_number            IN NUMBER,
  p_COLLECTIVE_BARGAIN_FLAG IN VARCHAR2,
  p_NO_OF_HRS_PART_TIME     IN VARCHAR2 ,
  p_NO_OF_HRS_SEASONAL      IN VARCHAR2 ,
  p_NO_OF_HRS_CURRENT       IN VARCHAR2,
  p_NEW_EE_MONTH_SERVC      IN VARCHAR2,
  p_MIN_AGE_REQ             IN VARCHAR2 ,
  P_EE_EXCLUDE_PLAN_FLAG    IN VARCHAR2,
  p_carrier_flag            IN VARCHAR2,
  p_union_ee_join_flag      IN VARCHAR2,
  p_enrollment_option       IN VARCHAR2,
  P_user_id                 IN NUMBER,
  x_error_status OUT VARCHAR2,
  x_error_message OUT VARCHAR2 );
  */
  --- Added by rprabu 21/08/2018 for FSA enrollment Update_Eligibile_Admin_Option1,
  ---UPDATE_HRA_ADMIN_OPTION1 , UPDATE_HRA_ADMIN_OPTION2
    procedure update_hra_admin_option1 (
        p_entrp_id                in number,
        p_ndt_preference          in varchar2,
        p_batch_number            in number,
        p_carrier_flag            in varchar2,
        p_additional_service_flag in varchar2,  --- param added by rprabu for the ticket  7678 on 05/15/2018
        p_enrollment_option       in varchar2,
        x_error_status            out varchar2,
        x_error_message           out varchar2
    );

    procedure update_hra_admin_option2 (
        p_entrp_id                in number,
        p_batch_number            in number,
        p_collective_bargain_flag in varchar2,
        p_no_of_hrs_part_time     in varchar2,
        p_no_of_hrs_seasonal      in varchar2,
        p_no_of_hrs_current       in varchar2,
        p_new_ee_month_servc      in varchar2,
        p_minimum_age             in varchar2, --- param added by rprabu for the ticket  6346 on 09/11/2018
        p_min_age_req             in varchar2,
        p_ee_exclude_plan_flag    in varchar2,
        p_union_ee_join_flag      in varchar2,
        p_user_id                 in number,
        x_error_status            out varchar2,
        x_error_message           out varchar2
    );

    procedure update_hra_invoice_bank_info (
        p_batch_number               in varchar2,
        p_entrp_id                   in number,
        p_salesrep_flag              in varchar2,    -- Ticket #7092 added by rprabu 23/10/2018
        p_salesrep_id                in number,
        p_pay_acct_fees              in varchar2,
        p_invoice_flag               in varchar2,
        p_hra_copy_plan_docs         in varchar2,
        p_funding_option             in varchar2,
        p_bank_name                  in varchar2,
        p_account_type               in varchar2,
        p_routing_num                in varchar2,
        p_account_num                in varchar2,
        p_acct_usage                 in varchar2,
        p_payment_method             in varchar2,
        p_page_validity              in varchar2,    -- Added by prabu for Ticket#7699
        p_bank_authorize             in varchar2,     -- Added by Jaggi ##9602
        p_pay_monthly_fees_by        in varchar2,     -- Added by Jaggi #11263
        p_monthly_fee_payment_method in varchar2,     -- Added by Jaggi #11263
        p_funding_payment_method     in varchar2,     -- Added by Jaggi #11263
        x_error_status               out varchar2,
        x_error_message              out varchar2
    );

    procedure process_hra_enrollment_renewal (
        p_batch_number       in number,
        p_entrp_id           in number,
        p_user_id            in number
      --Added Renewal parameters
        ,
        p_broker_name        in varchar2 default null,
        p_broker_license_num in varchar2 default null,
        p_broker_contact     in varchar2_tbl,
        p_broker_contact_id  in varchar2_tbl,
        p_broker_email       in varchar2_tbl,
        p_ga_name            in varchar2 default null,
        p_ga_license_num     in varchar2 default null,
        p_ga_contact         in varchar2_tbl,
        p_ga_contact_id      in varchar2_tbl,
        p_ga_email           in varchar2_tbl,
        p_send_invoice       in varchar2 default null,
        p_bank_acct_id       out number,                  -- Added by Swamy for Ticket#12309
        x_error_status       out varchar2,
        x_error_message      out varchar2
    );

    procedure create_coverage_data (
        p_covg_tier            in varchar2_tbl,
        p_funding_amount       in varchar2_tbl,
        p_covg_tier2           in varchar2_tbl,
        p_funding_amount2      in varchar2_tbl,
        p_batch_number         in number,
        p_user_id              in number,
        p_rollover_amount      in varchar2_tbl,
        p_acc_id               in number,
        p_covg_tier_type       in varchar2,
        p_enrollment_detail_id in number,
        p_source               in varchar2 default null,
        x_error_status         out varchar2,
        x_error_message        out varchar2
    );

    procedure insert_user_bank_acct (
        p_acc_num          in varchar2,
        p_display_name     in varchar2,
        p_bank_acct_type   in varchar2,
        p_bank_routing_num in varchar2,
        p_bank_acct_num    in varchar2,
        p_bank_name        in varchar2,
        p_user_id          in number,
        p_acct_usage       in varchar2,
        x_bank_acct_id     out number,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    );
  /*Ticket#5469 */
-- Below type is added by swamy to store the details of the Benifit plan Information.
    type er_cobra_plan_t is record (
            insurance_company_name  compliance_plan_staging.insurance_company_name%type,
            plan_name               compliance_plan_staging.plan_name%type,
            plan_type               compliance_plan_staging.plan_type%type,
            governing_state         compliance_plan_staging.governing_state%type,
            plan_start_date         compliance_plan_staging.plan_start_date%type,
            plan_end_date           compliance_plan_staging.plan_end_date%type,
            self_funded_flag        compliance_plan_staging.self_funded_flag%type,
            conversion_flag         compliance_plan_staging.conversion_flag%type,
            bill_cobra_premium_flag compliance_plan_staging.bill_cobra_premium_flag%type,
            coverage_terminate      compliance_plan_staging.coverage_terminate%type,
            age_rated_flag          compliance_plan_staging.age_rated_flag%type,
            ee_premium              compliance_plan_staging.ee_premium%type,
            ee_spouse_premium       compliance_plan_staging.ee_spouse_premium%type,
            ee_child_premium        compliance_plan_staging.ee_child_premium%type,
            ee_children_premium     compliance_plan_staging.ee_children_premium%type,
            ee_family_premium       compliance_plan_staging.ee_family_premium%type,
            spouse_premium          compliance_plan_staging.spouse_premium%type,
            child_premium           compliance_plan_staging.child_premium%type,
            spouse_child_premium    compliance_plan_staging.spouse_child_premium%type,
            carrier_contact_name    compliance_plan_staging.carrier_contact_name%type,
            carrier_contact_email   compliance_plan_staging.carrier_contact_email%type,
            carrier_phone_no        compliance_plan_staging.carrier_phone_no%type,
            carrier_addr            compliance_plan_staging.carrier_addr%type,
            plan_number             compliance_plan_staging.plan_number%type,
            policy_number           compliance_plan_staging.policy_number%type,
            description             compliance_plan_staging.description%type,
            error_status            varchar2(1),
            error_message           varchar2(1000)
    );
    type ret_re_cobra_plan_t is
        table of er_cobra_plan_t;
    procedure set_payment (
        p_entrp_id                    in number,
        p_batch_number                in number,
        p_salesrep_flag               in online_compliance_staging.salesrep_flag%type,
        p_salesrep_id                 in online_compliance_staging.salesrep_id%type,
        p_cp_invoice_flag             in varchar2,
        p_fees_payment_flag           in varchar2,
        p_fees_remitance_flag         in varchar2,
        p_acct_payment_fees           in varchar2,
          /*Ticket#5020 */
        p_bank_name                   in online_compliance_staging.bank_name%type,
        p_bank_acc_type               in online_compliance_staging.bank_acc_type%type,
        p_routing_number              in online_compliance_staging.routing_number%type,
        p_bank_acc_num                in online_compliance_staging.bank_acc_num%type,
        p_page_validity               in varchar2,
        p_bank_acct_id                in number,               -- Added by Joshi for 9141
        p_bank_authorize              in varchar2,             -- Added by Jaggi ##9602
        p_user_id                     in number,               -- 10747new
        p_bank_acct_usage             in varchar2,             -- 10747new
          -- Added by Jaggi #11262
        p_optional_bank_name          in online_compliance_staging.optional_bank_name%type,
        p_optional_bank_acc_type      in online_compliance_staging.optional_bank_acc_type%type,
        p_optional_routing_number     in online_compliance_staging.optional_routing_number%type,
        p_optional_bank_acc_num       in online_compliance_staging.optional_bank_acc_num%type,
        p_remit_bank_name             in online_compliance_staging.remit_bank_name%type,
        p_remit_bank_acc_type         in online_compliance_staging.remit_bank_acc_type%type,
        p_remit_routing_number        in online_compliance_staging.remit_routing_number%type,
        p_remit_bank_acc_num          in online_compliance_staging.remit_bank_acc_num%type,
        p_pay_optional_fees_by        in varchar2,
        p_optional_fee_payment_method in varchar2,
        p_optional_fee_bank_acct_id   in varchar2,
        p_optional_bank_authorize     in varchar2,
        p_remit_bank_authorize        in varchar2,
        x_error_status                out varchar2,
        x_error_message               out varchar2
    );
  -- Below type added by swamy to get the contact details
    type er_invoice_info_t is record (
            contact_id    contact_leads.contact_id%type,
            contact_name  contact_leads.first_name%type,
            job_title     contact_leads.job_title%type,
            phone_num     contact_leads.phone_num%type,
            email         contact_leads.email%type,
            contact_fax   contact_leads.contact_fax%type,
            contact_type  contact_leads.contact_type%type,
            error_status  varchar2(10),
            error_message varchar2(500)
    );
    type ret_er_invoice_info_t is
        table of er_invoice_info_t;
  -- Below function added by swamy function to get the contact details for cobra plan invoice information (page 3 in the enrolment)
    function get_cobra_contact_info (
        p_entrp_id     in number,
        p_contact_id   in number,
        p_account_type varchar2
    )   --Ticket 7619 added by rprabu 29/01/2019.
     return ret_er_invoice_info_t
        pipelined
        deterministic;
  /*Ticket 5518 */
    procedure create_emp_plan_contacts (
        p_admin_type               varchar2,
        p_plan_admin_name          varchar2,
        p_contact_type             varchar2,
        p_contact_name             varchar,
        p_phone_num                varchar2,
        p_email                    varchar2,
        p_address1                 varchar2,
        p_address2                 varchar2,
        p_city                     varchar2,
        p_state                    varchar2,
        p_zip_code                 varchar,
        p_plan_agent               varchar2,
        p_description              varchar2,
        p_agent_name               varchar2,
        p_legal_agent_contact_type varchar2,
        p_legal_agent_contact      varchar2,
        p_legal_agent_phone        varchar2,
        p_legal_agent_email        varchar2,
        p_trust_fund               varchar2,
        p_trustee_name             varchar2,
        p_trustee_contact_type     varchar2,
        p_trustee_contact_name     varchar2,
        p_trustee_contact_phone    varchar2,
        p_trustee_contact_email    varchar2,
        p_user_id                  number,
        p_entrp_id                 number,
        p_batch_number             number,
        x_error_status             out varchar2,
        x_error_message            out varchar2
    );
  --Ticket#5469
    function get_invalid_page (
        p_entrp_id     in number,
        p_batch_number in number
    ) return varchar2;
  --Ticket#5469
    procedure delete_file (
        p_batch_number  in varchar2,
        p_doc_id        in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );
  /* Ticket#5862 POP Reconstrction */
    procedure upsert_pop_staging (
        p_entrp_id                    in number,
        p_batch_number                in number,
        p_state_of_org                in varchar2,
        p_yr_end_date                 in varchar2,
        p_entity_type                 in varchar2,
        p_company_tax                 in varchar2,             -- Added by jaggi ##9604
        p_name                        in varchar2,
        p_affl_flag                   in varchar2,
        p_cntrl_grp_flag              in varchar2,
        p_aff_name                    in varchar2_tbl,
        p_cntrl_grp                   in varchar2_tbl,
        p_user_id                     in number,
        p_page_validity               in varchar2,
        p_source                      in varchar2,             -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
        p_state_main_office           in varchar2,              -- Added for Ticket#11037 by Swamy
        p_state_govern_law            in varchar2,              -- Added for Ticket#11037 by Swamy
        p_affliated_diff_ein          in varchar2,              -- Added for Ticket#11037 by Swamy
        p_type_entity_other           in varchar2,              -- Added for Ticket#11037 by Swamy
        p_affliated_ein               in varchar2_tbl,              -- Start Added for Ticket#11037 by Swamy
        p_affliated_entity_type       in varchar2_tbl,
        p_affliated_entity_type_other in varchar2_tbl,
        p_affliated_address           in varchar2_tbl,
        p_affliated_city              in varchar2_tbl,
        p_affliated_state             in varchar2_tbl,
        p_affliated_zip               in varchar2_tbl,             -- END  of addition for Ticket#11037 by Swamy
        x_error_status                out varchar2,
        x_error_message               out varchar2
    );
  /*Ticket#5862 */
    procedure create_pop_plan_staging (
        p_entrp_id               in number,
        p_plan_name              in varchar2,
        p_plan_number            in varchar2,
        p_plan_type              in varchar2,
        p_take_over_flag         in varchar2,
        p_short_plan_yr_flag     in varchar2,
        p_plan_start_date        in varchar2,
        p_plan_end_date          in varchar2,
        p_org_eff_date           in varchar2,
        p_eff_date               in varchar2,
        p_eff_date_sterling      in varchar2,
        p_tot_no_ees             in number,
        p_tot_eligib_ees         in varchar2,
        p_ga_flag                in varchar2,
        p_ga_id                  in varchar2,
        p_user_id                in number,
        p_page_validity          in varchar2,
        p_batch_number           in number,
        p_tot_cost               in number,
        p_plan_id                in number default null,
        p_flg_plan_name          in varchar2 default 'N', -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
        p_wrap_opt_flg           in varchar2 default 'N', -- Added By Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
        p_plan_doc_ndt_flag      in varchar2,  --- Added by rprabu Ticket #7832
        p_short_plan_yr_end_date in varchar2, -- Added by Joshi for 12135.
        x_er_ben_plan_id         out number,
        x_error_status           out varchar2,
        x_error_message          out varchar2
    );
  /*Ticket#5862 */
  ---PROCEDURE Validate_contact(p_contact_id IN NUMBER, p_entrp_id IN NUMBER );
  -- Added by rprabu two parameters as per requirment for ticket 6346
    procedure validate_contact (
        p_contact_id   in number,
        p_entrp_id     in number,
        p_batch_number in number,
        p_account_type in varchar2 default null,   -- P_batch_number and p_account_type added by rprabu  on 08/08/2018 for the tickets 6346 and 6377         );
        p_source       in varchar2 default null    -- Added by Swamy for Ticket#9324 on 16/07/2020
    );
  /* Ticket#5020.Insert plan contacts data in staging table for POP */
    procedure create_emp_plan_contacts_stage (
        p_admin_type               varchar2,
        p_plan_admin_name          varchar2,
        p_contact_type             varchar2,
        p_contact_name             varchar,
        p_phone_num                varchar2,
        p_email                    varchar2,
        p_address1                 varchar2,
        p_address2                 varchar2,
        p_city                     varchar2,
        p_state                    varchar2,
        p_governing_state          varchar2, -- 7832 Rprabu
        p_zip_code                 varchar,
        p_plan_agent               varchar2,
        p_description              varchar2,
        p_agent_name               varchar2,
        p_legal_agent_contact_type varchar2,
        p_legal_agent_contact      varchar2,
        p_legal_agent_phone        varchar2,
        p_legal_agent_email        varchar2,
        p_trust_fund               varchar2,
        p_trustee_name             varchar2,
        p_trustee_contact_type     varchar2,
        p_trustee_contact_name     varchar2,
        p_trustee_contact_phone    varchar2,
        p_trustee_contact_email    varchar2,
        p_user_id                  number,
        p_entrp_id                 number,
        p_batch_number             number,
        p_page_validity            in varchar2, -- rprabu 7946 26/03/2020
        x_error_status             out varchar2,
        x_error_message            out varchar2
    );
  -- Start Addition Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294
    type rec_ben_codes is record (
            benefit_code_id          number,
            benefit_code_name        varchar2(1000),
            meaning                  varchar2(1000),
            eligibility              varchar2(1000),
            er_cont_pref             varchar2(1000),
            ee_cont_pref             varchar2(1000),
            er_ee_contrib_lng        varchar2(1000),
            refer_to_doc             varchar2(100),
            eligibility_refer_to_doc varchar2(100),
            voluntary_life_add_info  varchar2(4000)
    ); -- jaggi ##9199
    type tbl_ben_codes is
        table of rec_ben_codes;
    type rec_welfare_ben_plans is record (
            grandfathered           varchar2(100),
            self_administered       varchar2(100),
            subsidy_in_spd_apndx    varchar2(100),
            clm_lang_in_spd         varchar2(100),
            wrap_opt_flg            varchar2(1),
            collective_bargain_flag varchar2(1),
            special_inst            varchar2(1000),
            erisa_wrap_doc_type     varchar2(1)   -- Added by Swamy for Ticket#8684 on 19/05/2020
    );
    type tbl_welfare_ben_plans is
        table of rec_welfare_ben_plans;
  --Type Varchar2_Tbl Is Table Of Varchar2(300) Index By Binary_Integer;
    type get_plan_notices_row is record (
            notice_type   varchar2(100),
            description   varchar2(1000),
            flg_no_notice varchar2(100),
            flg_addition  varchar2(100),
            error_message varchar2(1000),
            error_status  varchar2(100)
    );
    type get_plan_notices_row_t is
        table of get_plan_notices_row;
  -- Record Creation For Employee Censes Block In Erisa Enrollment
    type get_emp_censes_row is record (
            no_off_ees              number,
            no_of_eligible          number,
            flg_5500                varchar2(100),
            flg_final_filing        varchar2(1),
            flg_plan_no_use         varchar2(100),
            wrap_plan_5500          varchar2(100),
            collective_bargain_flag varchar2(10),
            error_status            varchar2(1),
            error_message           varchar2(500)
    );
    type get_emp_censes_row_t is
        table of get_emp_censes_row;
    type tbl_aca_eligibility_stage is
        table of erisa_aca_eligibility_stage%rowtype;
    type rec_plan_employer_contacts is record (
            plan_admin_name          varchar2(100),
            contact_type             varchar2(100),
            contact_name             varchar2(100),
            phone_num                varchar2(100),
            email                    varchar2(100),
            address1                 varchar2(1000),
            address2                 varchar2(1000),
            city                     varchar2(100),
            state                    varchar2(100),
            zip_code                 varchar2(100),
            plan_agent               varchar2(100),
            description              varchar2(100),
            agent_name               varchar2(100),
            legal_agent_contact      varchar2(100),
            legal_agent_phone        varchar2(100),
            legal_agent_email        varchar2(100),
            trust_fund               varchar2(2),
            created_by               number,
            creation_date            date,
            last_updated_by          number,
            last_update_date         date,
            record_id                number,
            entity_id                number,
            batch_number             number,
            admin_type               varchar2(100),
            trustee_name             varchar2(100),
            trustee_contact_type     varchar2(100),
            trustee_contact_name     varchar2(100),
            trustee_contact_phone    varchar2(100),
            trustee_contact_email    varchar2(100),
            legal_agent_contact_type varchar2(100),
            governing_state          varchar2(2)
    );   --- 7832 rprabu 29/05/2019
    type tbl_plan_employer_contacts is
        table of rec_plan_employer_contacts;
    type rec_tot_eligible_emp is record (
            rate_plan_detail_id number,
            line_list_price     number,
            coverage_type       varchar2(30)
    );
    type tbl_tot_eligible_emp is
        table of rec_tot_eligible_emp;
    type rto_api_plan_doc_request_t is record (
        col1 clob
    );
    type ret_rto_api_plan_doc_request is
        table of rto_api_plan_doc_request_t;
    function get_plan_details (
        p_entity_id    in number,
        p_batch_number in number,
        p_flg_block    in varchar2
    ) return tbl_ben_codes
        pipelined;

    procedure insert_erisa_eligib_req (
        p_entity_id               in number,
        p_user_id                 in number,
        p_benefit_code_name       in varchar2_tbl,
        p_others_name             in varchar2_tbl,
        p_batch_number            in number,
        p_entity_type             in varchar2,
        p_eligibility             in varchar2_tbl,
        p_er_ee_cont_pref         in varchar2_tbl,
        p_employer_amount         in varchar2_tbl,
        p_employee_amount         in varchar2_tbl,
        p_external_doc            in varchar2_tbl,
        p_eligibility_refer_doc   in varchar2_tbl,  -- added by Josi for 7791.
        p_voluntary_life_add_info in varchar2,     -- added by jaggi for 9199.
        p_flg_block               in varchar2,
        x_error_status            out varchar2,
        x_error_message           out varchar2
    );

    procedure insert_plan_notices_stage (
        p_batch_number  in number,
        p_entrp_id      in number,
        p_ben_plan_id   in number,
        p_notice_type   in varchar2_tbl,
        p_flg_no_notice in varchar2,
        p_flg_addition  in varchar2,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

    function get_plan_notices_stage (
        p_batch_number in number,
        p_entrp_id     in number,
        p_lookup_name  in varchar2
    ) return get_plan_notices_row_t
        pipelined
        deterministic;

    procedure upsert_emp_census_stage (
        p_entrp_id             in number,
        p_batch_number         in number,
        p_tot_emp              in number,
        p_tot_eligible_emp     in number,
        p_flg_5500             in varchar2,
        p_flg_final_filing     in varchar2,
        p_flg_plan_no_use      in varchar2,
        p_wrap_plan_5500       in varchar2,
        p_user_id              in number,
        p_erissa_wrap_doc_type in varchar2 default null,   -- Added by Swamy for Ticket#8684 on 19/05/2020
        x_error_status         out varchar2,
        x_error_message        out varchar2
    );

    function get_employee_censes (
        p_batch_number in number,
        p_entrp_id     in number
    ) return get_emp_censes_row_t
        pipelined;

    procedure insert_ar_quote (
        p_batch_number        in number,
        p_entrp_id            in number,
        p_account_type        in varchar2,
        p_rate_plan_id        in varchar2_tbl,
        p_rate_plan_detail_id in varchar2_tbl,
        p_list_price          in varchar2_tbl,
        p_user_id             in varchar2,
        x_error_status        out varchar2,
        x_error_message       out varchar2
    );

    procedure erisa_stage_to_main (
        p_batch_number  in number,
        p_entrp_id      in number,
        p_account_type  in varchar2,
        p_user_id       in varchar2,
        p_source        in varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

    procedure upsert_welfare_ben_plans (
        p_batch_number            in number,
        p_entrp_id                in number,
        p_collective_bargain_flag in varchar2,
        p_grandfathered           in varchar2,
        p_self_administered       in varchar2,
        p_subsidy_in_spd_apndx    in varchar2,
        p_clm_lang_in_spd         in varchar2,
        p_wrap_opt_flg            in varchar2,
        p_special_inst            in varchar2,
        p_user_id                 in number,
        x_error_status            out varchar2,
        x_error_message           out varchar2
    );

    function get_welfare_ben_plans (
        p_batch_number in number,
        p_entrp_id     in number
    ) return tbl_welfare_ben_plans
        pipelined;

    procedure plan_arrange_options (
        p_entrp_id             in number,
        p_plan_name            in varchar2,
        p_plan_number          in varchar2,
        p_plan_type            in varchar2,
        p_short_plan_yr_flag   in varchar2,
        p_plan_start_date      in varchar2,
        p_plan_end_date        in varchar2,
        p_org_eff_date         in varchar2,
        p_eff_date             in varchar2,
        p_user_id              in number,
        p_page_validity        in varchar2,
        p_batch_number         in number,
        p_plan_id              in number,
        p_flg_plan_name        in varchar2,
        p_flg_pre_adop_pln     in varchar2,
        p_erissa_wrap_doc_type in varchar2, -- added by Joshi for 7791
        x_er_ben_plan_id       out number,
        x_error_status         out varchar2,
        x_error_message        out varchar2
    );

    procedure aca_eligibility (
        p_ben_plan_id                 in number,
        p_aca_ale_flag                in varchar2,
        p_variable_hour_flag          in varchar2,
        p_irs_lbm_flag                in varchar2,
        p_intl_msrmnt_period          in varchar2,
        p_intl_msrmnt_start_date      in varchar2,
        p_intl_admn_period            in varchar2,
        p_define_intl_msrmnt_period   in varchar2,
        p_stblty_period               in varchar2,
        p_fte_hrs                     in varchar2,
        p_fte_salary_msmrt_period     in varchar2,
        p_fte_hourly_msmrt_period     in varchar2,
        p_fte_other_msmrt_period      in varchar2,
        p_fte_other_ee_name           in varchar2,
        p_fte_look_back               in varchar2,
        p_fte_lkp_salary_msmrt_period in varchar2,
        p_fte_lkp_hourly_msmrt_period in varchar2,
        p_fte_lkp_other_msmrt_period  in varchar2,
        p_fte_lkp_other_ee_name       in varchar2,
        p_msrmnt_period               in varchar2,
        p_msrmnt_start_date           in varchar2,
        p_msrmnt_end_date             in varchar2,
        p_stblt_start_date            in varchar2,
        p_stblt_period                in varchar2,
        p_stblt_end_date              in varchar2,
        p_fte_same_period_resume_date in varchar2,
        p_fte_diff_period_resume_date in varchar2,
        p_fte_same_period_select      in varchar2,
        p_fte_diff_period_select      in varchar2,
        p_admn_start_date             in varchar2,
        p_admn_period                 in varchar2,
        p_admn_end_date               in varchar2,
        p_mnthl_msrmnt_flag           in varchar2,
        p_same_prd_bnft_start_date    in varchar2,
        p_new_prd_bnft_start_date     in varchar2,
        p_user_id                     in number,
        p_entrp_id                    in number,
        p_batch_number                in number,
        x_error_status                out varchar2,
        x_error_message               out varchar2
    );

    function get_aca_eligibility (
        p_batch_number in number,
        p_entrp_id     in number
    ) return tbl_aca_eligibility_stage
        pipelined;

    function get_plan_employer_contacts (
        p_batch_number in number,
        p_entrp_id     in number
    ) return tbl_plan_employer_contacts
        pipelined;

    procedure upsert_page_validity (
        p_batch_number  in number,
        p_entrp_id      in number,
        p_account_type  in varchar2,
        p_page_no       in varchar2,
        p_block_name    in varchar2,
        p_validity      in varchar2,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

    function get_page_validity (
        p_batch_number in number,
        p_entrp_id     in number,
        p_account_type in varchar2
    ) return varchar2;
  --- added by rprabu on 22/08/2018 for 6346
    type page_validity_row_t is record (
            page_no    number,
            block_name varchar2(200),
            validity   varchar2(1)   ---9392 rprabu
    );
    type page_validity_record_t is
        table of page_validity_row_t;
  --- added by rprabu on 22/08/2018 for 6346
    function get_page_validity_details (
        p_batch_number in number,
        p_entrp_id     in number,
        p_account_type in varchar2
    ) return page_validity_record_t
        pipelined
        deterministic;
--- added by rprabu on 06/10/2020  for Ticket#9392
    function get_ga_er_details (
        p_batch_number in number,
        p_entrp_id     in number,
        p_account_type in varchar2
    ) return page_validity_record_t
        pipelined
        deterministic;

    function get_tot_eligible_emp (
        p_batch_number in number
    ) return tbl_tot_eligible_emp
        pipelined;
  -- End Addition Swamy For Development Of Erisa Enrollment Session To Staging Ticket#6294

   /*Created for Ticket#7016 on 21/11/2018 */
    procedure update_hsa_staging (
        p_entrp_id      in number,
        p_peo_ein       in number,
        p_peo_flag      in varchar2,
        p_salesrep_flag in varchar2,
        p_salesrep_id   in number,
        p_user_id       in number,
        p_batch_num     in number,
        p_page_validity in varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

  /*Created for ticket#7016 on 21/11/2018 */
    procedure update_hsa_plan_staging (
        p_entrp_id           in number,
        p_plan_code          in number,
        p_mon_fees_paid_by   in varchar2,
        p_ann_fees_paid_by   in varchar2,
        p_debit_card_allowed in varchar2,
        p_user_id            in number,
        p_subscribe_to_acn   in varchar2,
        p_batch_num          in number,
        p_page_validity      in varchar2,
        x_error_status       out varchar2,
        x_error_message      out varchar2
    );

      /*Created for ticket#7016 on 21/11/2018 */
    type er_hsa_info is record (
            peo                varchar2(10),
            peo_tax_id         varchar2(100),
            salesrep_id        number,
            salesrep_flag      varchar2(2),
            salesrep_name      varchar2(100),
            plan_code          varchar2(10),
            maint_fee_paid_by  varchar2(100),
            setup_fee_paid_by  varchar2(100),
            debit_card_allowed varchar2(10),
            subscribe_to_acn   varchar2(5),
            total_no_of_ee     number,            -- Added by Swamy for Ticket#7610
            no_of_eligible     number             -- Added by Swamy for Ticket#7610
    );
    type er_hsa_info_t is
        table of er_hsa_info;
      /*Created for ticket#7016 on 21/11/2018 */

    function get_hsa_info (
        p_entrp_id     in number,
        p_batch_number in number
    ) return er_hsa_info_t
        pipelined
        deterministic;

           /*Created for ticket#7016 on 21/11/2018 */
    procedure create_hsa_plan (
        p_entrp_id      in number,
        p_batch_num     in number,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

-- Added by swamy for Ticket#7610
    procedure update_hsa_employee_census (
        p_entrp_id       in number,
        p_user_id        in number,
        p_batch_num      in number,
        p_page_validity  in varchar2,
        p_no_of_ee       in number,
        p_no_of_eligible in number,
        x_error_status   out varchar2,
        x_error_message  out varchar2
    );

-- New procedure Validate_User_Bank_Acct_Stg is added by ticket#7699
    procedure validate_user_bank_acct_stg (
        p_entrp_id      in number,
        p_batch_num     in number,
        p_acct_type     in varchar2,
        p_page_validity out varchar2
    );

-- Added by Joshi for 10431
    type last_enroll_or_renewed_by_t is
        table of last_enroll_or_renewed_by_row;
    function get_enroll_or_renewed_by (
        p_entrp_id in number
    ) return last_enroll_or_renewed_by_t
        pipelined
        deterministic;

-- Added by Jaggi #11263
    function get_cobra_bank_details (
        p_entrp_id     in number,
        p_batch_number in number
    ) return sys_refcursor;

-- Added by Jaggi #11263
    function get_fhra_bank_details (
        p_entrp_id     in number,
        p_batch_number in number,
        p_source       in varchar2
    ) return sys_refcursor;

-- Added by Jaggi #11602
    procedure upsert_rto_api_plan_doc (
        p_entrp_id      in number,
        p_acc_id        in number,
        p_ben_plan_id   in number,
        p_batch_number  in number,
        p_user_id       in number,
        p_source        in varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

-- Added by Jaggi #11602
--Function Get_Rto_Api_Plan_Doc_Request(p_batch_number IN NUMBER DEFAULT NULL)  RETURN ret_Rto_Api_Plan_Doc_Request PIPELINED DETERMINISTIC;
-- Added by Swamy #11602
    function get_rto_api_plan_doc_request (
        p_batch_number in number default null
    ) return ret_rto_api_plan_doc_request
        pipelined
        deterministic;

-- Added by Swamy for Ticket#12309
    procedure fsa_hra_enroll_upsert_page_validity (
        p_entrp_id      in number,
        p_account_type  in varchar2,
        p_batch_number  in number,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

end pc_employer_enroll;
/


-- sqlcl_snapshot {"hash":"d8d6544c73d951d668a2c7c42db297560d27883f","type":"PACKAGE_SPEC","name":"PC_EMPLOYER_ENROLL","schemaName":"SAMQA","sxml":""}