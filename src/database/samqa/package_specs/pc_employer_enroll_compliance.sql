create or replace package samqa.pc_employer_enroll_compliance is
    type varchar2_tbl is
        table of varchar2(300) index by binary_integer;
    procedure upsert_form_5500_employer_info (
        p_entrp_id                    in number,
        p_batch_number                in number,
        p_company_contact_entity      in varchar2,
        p_company_contact_others      in varchar2,
        p_company_contact_email       in varchar2,
        p_plan_admin_individual_name  in varchar2,
        p_emp_plan_sponsor_ind_name   in varchar2,
        p_disp_annual_report_ind_name in varchar2,
        p_disp_annual_report_phone_no in varchar2,
        p_form_5500_sub_option_flag   in varchar2,
        p_user_id                     in number,
        p_page_validity               in varchar2,
        x_error_status                out varchar2,
        x_error_message               out varchar2
    );

-- Added by Joshi for 7792.
    type erisa_plan_date_rec is record (
            plan_order      number,
            plan_start_date varchar2(15)
    );
    type erisa_plan_date_rec_t is
        table of erisa_plan_date_rec;
    function get_erisa_plan_dates (
        p_ein in varchar2
    ) return erisa_plan_date_rec_t
        pipelined
        deterministic;

-- code ends here

 -- Below Type added by rprabu function FORM_5500 Revamp  ticket 7015
    type tbl_form_5500_plan_staging is
        table of online_form_5500_plan_staging%rowtype;
    type get_report_type_row is record (
            lookup_code   varchar2(100),
            description   varchar2(1000),
            error_message varchar2(1000),
            error_status  varchar2(100)
    );
    type get_report_type_row_t is
        table of get_report_type_row;
    type bank_info_record is record (
            bank_acct_id       bank_accounts.bank_acct_id%type,
            bank_name          bank_accounts.bank_name%type,
            bank_acct_type     bank_accounts.bank_acct_type%type,
            bank_routing_num   bank_accounts.bank_routing_num%type,
            bank_acct_num      bank_accounts.bank_acct_num%type,
            bank_account_usage bank_accounts.bank_account_usage%type,
            giac_verify        bank_accounts.giac_verify%type,
            giac_authenticate  bank_accounts.giac_authenticate%type,
            giac_response      bank_accounts.giac_response%type,
            business_name      bank_accounts.business_name%type
    );
    type bank_info_row_t is
        table of bank_info_record;
    function get_plan_fund_code return get_report_type_row_t
        pipelined
        deterministic;

    function get_benefit_codes return get_report_type_row_t
        pipelined
        deterministic;

 -- Below Type added by rprabu function FORM_5500 Revamp  ticket 7015
    function get_form_5500_plan_staging (
        p_batch_number         in number,
        p_entrp_id             in number,
        p_enrollment_detail_id in number
    ) return tbl_form_5500_plan_staging
        pipelined;

    procedure upsert_form_5500_plan_staging (
        p_entrp_id                     in number,
        p_batch_number                 in number,
        p_enrollment_detail_id         in out number,
        p_plan_name                    in varchar2,
        p_plan_number                  in varchar2,
        p_short_plan_year_flag         in varchar2,
        p_extention_flag               in varchar2,
        p_dfvc_program_flag            in varchar2,
        p_other_feature_code           in varchar2,
        p_last_employer_name           in varchar2,
        p_last_plan_name               in varchar2,
        p_last_ein                     in varchar2,
        p_last_plan_number             in varchar2,
        p_erisa_wrap_plan_flag         in varchar2,
        p_l_day_active_participants    in number,
   ---   P_Retired_emp_enroll_L_day           IN NUMBER,
        p_enrolled_empl_1st_day_pln_yr in number,
        p_effective_plan_date          in varchar2,
        p_plan_start_date              in varchar2,
        p_plan_end_date                in varchar2,
        p_plan_type                    in varchar2,
        p_active_participants          in number,
        p_recv_benefits                in number,
        p_future_benefits              in number,
        p_total_no_ee                  in number,
        p_is_coll_plan                 in varchar2,
        p_no_of_schedule_a_doc         in number,
        p_sponsor_name                 in varchar2,
        p_sponsor_contact_name         in varchar2,
        p_sponsor_email                in varchar2,
        p_sponsor_tel_num              in varchar2,
        p_sponsor_business_code        in varchar2,
        p_sponsor_ein                  in varchar2,
        p_admin_name_sponsor_flag      in varchar2,
        p_admin_name                   in varchar2,
        p_admin_contact_name           in varchar2,
        p_admin_email                  in varchar2,
        p_admin_tel_num                in varchar2,
        p_admin_business_code          in varchar2,
        p_admin_ein_sponsor_flag       in varchar2,
        p_admin_ein                    in varchar2,
        p_admin_addr                   in varchar2,
        p_admin_city                   in varchar2,
        p_admin_zip                    in varchar2,
        p_admin_state                  in varchar2,
        p_pre_sponsor_name_ein_flag    in varchar2,
        p_previous_sponsor_name        in varchar2,
        p_previous_sponsor_ein         in varchar2,
        p_erisa_wrap_flag              in varchar2,     ---------P_Is_5500
        p_collective_plan_flag         in varchar2, -------------P_Is_Collective_Plan
        p_report_type                  in varchar2_tbl,
        p_benefit_code_name            in varchar2_tbl,
        p_description                  in varchar2_tbl,
        p_benefit_code_fully_insured   in varchar2_tbl,
        p_benefit_code_self_insured    in varchar2_tbl,
        p_plan_fund_code               in varchar2,
        p_plan_benefit_code            in varchar2,
        p_rate_plan_id                 in varchar2_tbl,
        p_rate_plan_detail_id          in varchar2_tbl,
        p_list_price                   in varchar2_tbl,
        p_tot_price                    in varchar2,
        p_user_id                      in number,
        p_next_yr_short_plan_year_flag in varchar2,
        p_next_yr_plan_start_date      in varchar2,
        p_next_yr_plan_end_date        in varchar2,
        p_send_doc_later_flag          in varchar2,
        p_page_validity                in varchar2,
        x_error_status                 out varchar2,
        x_error_message                out varchar2
    );


  ---    /*Ticket#7015.FORM_5500 reconstruction */    Done by RPRABU 05/12/2018
    procedure process_form_5500_main_tables (
        p_entrp_id      in number,
        p_batch_number  in number,
        p_user_id       in number,
      /*Ticket#6834 */
        p_source        varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

-- Record Creation For rate plans  7015
    type get_benefit_plan_row is record (  	   --- Rate plans details
            rate_plan_ids        varchar2(1000),
            rate_plan_detail_ids varchar2(1000),
            list_prices          varchar2(1000),
			--   Report Type details
            notice_type          varchar2(4000),
            description          varchar2(4000),
            flg_no_notice        varchar2(100),
            flg_addition         varchar2(100),
			--  benefit codes details...
            benefit_code_id      varchar2(4000),
            benefit_code_name    varchar2(4000),
            fully_insured_flag   varchar2(1000),
            self_insured_flag    varchar2(1000),
            meaning              varchar2(4000),
            eligibility          varchar2(4000),
            er_cont_pref         varchar2(1000),
            ee_cont_pref         varchar2(1000),
            er_ee_contrib_lng    varchar2(1000),
            refer_to_doc         varchar2(4000),
            error_status         varchar2(1),
            error_message        varchar2(4000)
    );
    type get_benefit_plan_row_t is
        table of get_benefit_plan_row;

  -- Below  function rate Plans  added by rprabu function FORM_5500 Revamp  ticket 7015
--Function GET_Rate_Plans_Form_5500
    function get_benefit_plans_form_5500 (
        p_batch_number       in number,
        p_entrp_id           in number,
        p_enrollment_line_id in number,
        p_lookup_name        in varchar2
    ) return get_benefit_plan_row_t
        pipelined;


/*Ticket#5020.FORM_5500  Renewal*/
    procedure populate_renewal_data (
        p_batch_number   in number,
        p_entrp_id       in number,
        p_user_id        in number,
        p_page_validity  in varchar2,    -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
        p_bank_authorize in varchar2,    -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
        p_account_type   in varchar2    -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
    );



 -- Below Type added by rprabu function to get   BANK FUNCTIONALITY ticket 7015
/*Type Tbl_Online_Form_5500_Staging
IS
  TABLE OF Online_Form_5500_Staging%Rowtype;
*/

    type typ_tbl_online_form_5500_staging is record (
            entrp_id                   number,
            batch_number               number,
            enrollment_id              number,
            credit_payment_monthly_pre varchar2(1),
            payment_method             varchar2(100),
            acct_payment_fees          varchar2(100),
            grand_total_price          number(10),
            send_invoice               varchar2(1),
            pay_acct_fees              varchar2(10),
            salesrep_id                number(10),
            salesrep_flag              varchar2(1),
            bank_authorize             varchar2(1),
            bank_name                  varchar2(255),
            routing_number             varchar2(9),
            bank_acc_num               varchar2(20),
            bank_acc_type              varchar2(15),
            acct_usage                 varchar2(50),
            business_name              varchar2(50),
            giac_verify                varchar2(50),
            giac_authenticate          varchar2(50),
            giac_response              varchar2(50),
            bank_acct_stg_id           number,
            bank_status                varchar2(5)
    );
    type tbl_online_form_5500_staging is
        table of typ_tbl_online_form_5500_staging;

  ---    /*Ticket#7015.FORM_5500 reconstruction */    Done by RPRABU 15/12/2018
    function get_form_5500_inv_bank_info (
        p_batch_number  in number,
        p_entrp_id      in number,
        p_enrollment_id in number,
        p_account_type  in varchar2
    ) return tbl_online_form_5500_staging
        pipelined;

    procedure update_form_5500_inv_bank_info (
        p_batch_number               in varchar2,
        p_entrp_id                   in number,
        p_salesrep_flag              in varchar2,                  -- Ticket #6882
        p_salesrep_id                in number,
        p_invoice_flag               in varchar2,
        p_credit_payment_monthly_pre in varchar2,
        p_payment_method             in varchar2,
        p_acct_payment_fees          in varchar2,                 -- added by rprabu 30/07/2019
        p_page_validity              in varchar2,
        p_source                     in varchar2 default null,    -- Added by Swamy for Ticket#9324 on 16/07/2020
        p_user_id                    in number,           -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
        x_error_status               out varchar2,
        x_error_message              out varchar2
    );


  ---    /*Ticket#7015.FORM_5500 reconstruction */    Done by RPRABU 15/12/2018
/* Procedure Update_Form_5500_Inv_Bank_Info(
      P_Batch_Number                In VARCHAR2 ,
      P_Entrp_Id                    In Number,
      P_Salesrep_Flag               In VARCHAR2,                  -- Ticket #6882
      P_Salesrep_Id                 In Number,
      P_Invoice_Flag                In VARCHAR2,
      P_Credit_Payment_Monthly_Pre  In VARCHAR2,
      P_Bank_Name                   In VARCHAR2,
      P_Account_Type                In VARCHAR2,
      P_Routing_Num                 In VARCHAR2,
      P_Account_Num                 In VARCHAR2,
      P_Acct_Usage                  In VARCHAR2,
      P_Payment_Method              In VARCHAR2,
      p_Acct_Payment_Fees           IN VARCHAR2,                 -- added by rprabu 30/07/2019
	  P_Page_Validity               In VARCHAR2,
	  p_source                      IN VARCHAR2 DEFAULT NULL,    -- Added by Swamy for Ticket#9324 on 16/07/2020
      P_Bank_Authorize              IN VARCHAR2,                 -- Added by Jaggi ##9602
	  p_user_id                     In Number,           -- Added by Swamy for Ticket#10993(Dev Ticket#10747)
      p_giac_response               IN VARCHAR2,   -- Added by Swamy for Ticket#12527 
      p_giac_verify                 IN VARCHAR2,   -- Added by Swamy for Ticket#12527 
      p_giac_authenticate           IN VARCHAR2,   -- Added by Swamy for Ticket#12527 
      p_bank_acct_verified          IN VARCHAR2,   -- Added by Swamy for Ticket#12527 
      p_business_name               IN VARCHAR2,   -- Added by Swamy for Ticket#12527 
      p_existing_bank_flag          IN VARCHAR2,   -- Added by Swamy for Ticket#12527
      p_Bank_acct_stg_Id            IN NUMBER,     -- Added by Swamy for Ticket#12527
      p_bank_acct_id                IN NUMBER,     -- Added by Swamy for Ticket#12527
      x_bank_status                 Out VARCHAR2,  -- Added by Swamy for Ticket#12527 
      x_bank_status_message         Out VARCHAR2,  -- Added by Swamy for Ticket#12527 
      X_Error_Status                Out VARCHAR2,
      X_Error_Message               Out VARCHAR2 );
*/


    function get_census_number (
        p_entrp_id    number,
        p_census_code varchar2
    ) return number;

----------7998 done by swamy on 29/08/2019
    type get_rate_type_row is record (
            rate_plan_id  rate_plans.rate_plan_id%type,
            param_id      rate_plan_detail.rate_plan_detail_id%type,
            param         rate_plans.rate_plan_name%type,
            code          rate_plan_detail.coverage_type%type,
            description   rate_plan_detail.description%type,
            fee           varchar2(100),
            order_id      number,
            error_message varchar2(1000),
            error_status  varchar2(2)
    );
    type get_rate_type_row_t is
        table of get_rate_type_row;
    function get_rate_codes return get_rate_type_row_t
        pipelined
        deterministic;
    ----------7998 END done by swamy on 29/08/2019

-- Added by Joshi for 8471. To get the COBRA fee info
-- Code added by Joshi for 8741
    type cobra_fee_row_t is record (
            rate_plan_id        number,
            rate_plan_detail_id number,
            rate_plan_name      varchar2(1000),
            coverage_type       varchar2(1000),
            min_range           varchar2(2000),   --- 3933 rprabu 02/07/2019
            max_range           varchar2(2000),   --- 3933 rprabu 02/07/2019
            range               varchar2(2000),
            fee                 number
    );
    type cobra_fee_record_t is
        table of cobra_fee_row_t;
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
            carrier_name            compliance_plan_staging.carrier_name%type,
            carrier_contact_name    compliance_plan_staging.carrier_contact_name%type,
            carrier_contact_email   compliance_plan_staging.carrier_contact_email%type,
            carrier_phone_no        compliance_plan_staging.carrier_phone_no%type,
            carrier_addr            compliance_plan_staging.carrier_addr%type,
            plan_number             compliance_plan_staging.plan_number%type,
            policy_number           compliance_plan_staging.policy_number%type,
            description             compliance_plan_staging.description%type,
            cobra_fed_flag          compliance_plan_staging.cobra_fed_flag%type,   -- Swamy 05022024 #12000
            error_status            varchar2(1),
            error_message           varchar2(1000)
    );
    type ret_re_cobra_plan_t is
        table of er_cobra_plan_t;
    function get_cobra_fee (
        p_no_of_eligible number,
        p_fee_schedule   varchar2
    ) return cobra_fee_record_t
        pipelined
        deterministic;
-- moved below proc from pc_employer_enroll packge to here.
-- Joshi 8471.
    procedure upsert_cobra_staging (
        p_entrp_id            in number,
        p_batch_number        in number,
        p_tot_ees             in number,
        p_eff_date            in varchar2,
        p_rate_plan_id        in varchar2_tbl,
        p_rate_plan_detail_id in varchar2_tbl,
        p_rate_plan_name      in varchar2_tbl,
        p_list_price          in varchar2_tbl,
        p_tot_price           in number default null,
        p_user_id             in number,
        p_page_validity       in varchar2,
        p_billing_frequency   in varchar2,    -- 02/19/2020
        p_carrier_notify      in varchar2,    -- 02/19/2020
        x_error_status        out varchar2,
        x_error_message       out varchar2
    );
	  -----------------9392	 rprabu 29/09/2020
    procedure upsert_cobra_staging_comp_info (
        p_entrp_id      in number,
        p_batch_number  in number,
        p_eff_date      in varchar2,
        p_page_validity in varchar2,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

-- 8471 Ends here
--Added by Jagadeesh on 02/24 #8471
    procedure create_compliance_plan (
        p_entrp_id                in number,
        p_plan_name               in varchar2,
        p_insurance_company_name  in varchar2,
        p_governing_state         in varchar2,
        p_plan_start_date         in varchar2,
        p_plan_end_date           in varchar2,
        p_plan_type               in varchar2,
        p_description             in varchar2,
        p_self_funded_flag        in varchar2,
        p_conversion_flag         in varchar2,
        p_bill_cobra_premium_flag in varchar2,
        p_coverage_terminate      in varchar2,
        p_age_rated_flag          in varchar2,
        p_carrier_contact_name    in varchar2,
        p_policy_number           in varchar2,
        p_plan_number             in varchar2,
        p_carrier_name            in varchar2, -- added by Joshi for 8471
        p_carrier_contact_email   in varchar2,
        p_carrier_phone_no        in varchar2,
        p_carrier_addr            in varchar2,
        p_ee_premium              in varchar2,
        p_ee_spouse_premium       in varchar2,
        p_ee_child_premium        in varchar2,
        p_ee_children_premium     in varchar2,
        p_ee_family_premium       in varchar2,
        p_spouse_premium          in varchar2,
        p_child_premium           in varchar2,
        p_spouse_child_premium    in varchar2,
        p_user_id                 in number,
        p_page_validity           in varchar2,
        p_batch_number            in number,
        p_plan_id                 in number default null,
        p_renewed_ben_plan_id     in number,   -- Added by Swamy for Ticket#10431(Renewal Resubmit)
        p_cobra_fed_flag          in varchar2,   -- Swamy 05022024 #12000
        x_er_ben_plan_id          out number,
        x_error_status            out varchar2,
        x_error_message           out varchar2
    );

 --Added by Jagadeesh on 02/24 #8471
    procedure create_cobra_plan (
        p_entrp_id       in number,
        p_batch_number   in number,
        p_user_id        in number,
        x_er_ben_plan_id out number,
        x_error_status   out varchar2,
        x_error_message  out varchar2
    );

    function get_cobra_plan (
        p_plan_id in number
    ) return ret_re_cobra_plan_t
        pipelined
        deterministic;

-- Added by Swamy for Ticket#8684 on 19/05/2020
    procedure upsert_erisa_staging (
        p_entrp_id       in number,
        p_batch_number   in number,
        p_state_of_org   in varchar2,
        p_yr_end_date    in varchar2,
        p_entity_type    in varchar2,
        p_name           in varchar2,
        p_affl_flag      in varchar2,
        p_cntrl_grp_flag in varchar2,
        p_aff_name       in varchar2_tbl,
        p_cntrl_grp      in varchar2_tbl,
        p_user_id        in number,
        p_page_validity  in varchar2,
        p_source         in varchar2,
        p_city           in varchar2,
        p_zip            in varchar2,
        p_address        in varchar2,
        x_error_status   out varchar2,
        x_error_message  out varchar2
    );

 --As per Pier 9095 Added by Jagadeesh On 05/19/2020
    type compliance_renewal_data_row_t is record (
            state_of_org           varchar2(100),
            fiscal_yr_end          varchar2(100),
            type_of_entity         varchar2(100),
            company_tax            varchar2(2)     -- Added by jaggi ##9604
            ,
            company_tax_desc       varchar2(50)    -- Added by jaggi ##9604
            ,
            entity_name_desc       varchar2(100),
            affliated_flag         varchar2(2),
            cntrl_grp_flag         varchar2(2),
            plan_id                number,
            plan_type              varchar2(100),
            takeover_flag          varchar2(100),
            plan_number            varchar2(100),
            plan_name              varchar2(100) -- Added by Jaggi #9905
            ,
            plan_start_date        varchar2(100),
            plan_end_date          varchar2(100),
            short_plan_yr_flag     varchar2(100),
            flg_plan_name          varchar2(1),
            flg_pre_adop_pln       varchar2(1),
            ga_flag                varchar2(100),
            ga_id                  varchar2(100),
            org_eff_date           varchar2(100),
            effective_date         varchar2(100),
            eff_date_sterling      varchar2(100),
            no_of_eligible         varchar2(100),
            no_off_ees             number,
            erissa_erap_doc_type   varchar2(1),
            total_cost             number,
            plan_doc_ndt_flag      varchar2(1),
            address                varchar2(100),
            city                   varchar2(30),
            zip                    varchar2(10),
            state_main_office      varchar2(100)   -- Start code Added by Swamy for Ticket#11037
            ,
            state_govern_law       varchar2(100),
            affliated_diff_ein     varchar2(100),
            type_entity_other      varchar2(100)     -- End of code by Swamy for Ticket#11037
            ,
            short_plan_yr_end_date varchar2(100) -- Added by Joshi for 12135.
    );
    type compliance_renewal_data_t is
        table of compliance_renewal_data_row_t;
    function get_compliance_renewal_data (
        p_batch_number number,
        p_entrp_id     number
    ) return compliance_renewal_data_t
        pipelined
        deterministic;

 --Added by Swamy on 25/06/20 #9242
    procedure update_plan_staging (
        p_entrp_id             in number,
        p_batch_number         in number,
        p_enrollment_detail_id in number,
        p_page_validity        in varchar2,
        x_error_status         out varchar2,
        x_error_message        out varchar2
    );


 --Added by rprabu  on 05/08/20 #9141
    procedure update_app_signed_by_staging (
        p_entrp_id      in number,
        p_batch_number  in number,
        p_account_type  in varchar2,
        p_sign_type     in varchar2, -----who is signing
        p_contact_name  in varchar2,
        p_email         in varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

-- Added by rprabu  for 9141   on 18/08/2020
    type client_details_rec is record (
            account_status       number,
            account_descrtiption varchar2(500),
            no_of_clients        number
    );
    type client_details_rec_t is
        table of client_details_rec;

----------9141  done by rprabu  on 13/08/2020
    function get_client_details (
        p_entity_id   in number,
        p_entity_type in varchar2    -- Added by jaggi for Ticket#10848 on 05/09/2022
        ,
        p_acct_status in varchar2
    )   -- Added by Swamy for Ticket#9862 on 03/06/2021
     return client_details_rec_t
        pipelined
        deterministic;

-- Added by rprabu  for 9141   on 13/08/2020
    type employer_details_rec is record (
            acc_id                   number,
            acc_num                  varchar2(50),
            account_status           varchar2(50),
            acccount_description     varchar2(100),
            enrolle_type             varchar2(100),
            enrolled_by              varchar2(100),
            signed_by                varchar2(100),
            sign_type                varchar2(100),
            renewed_by               varchar2(100),      -- Added by Swamy for Ticket#11364(Broker)
            signature_account_status number,             -- Added by Swamy for Ticket#11364(Broker)
            renewed_by_id            number,               -- Added by Swamy for Ticket#11364(Broker)
            renewal_signed_by        varchar2(30),         -- Added by Swamy for Ticket#11364(Broker)
            renewal_sign_type        varchar2(30),         -- Added by Swamy for Ticket#11364(Broker)
            renewed_by_user_id       varchar2(30),          -- Added by Swamy for Ticket#11368(Broker)
            renewal_flag             varchar2(30),          -- Added by Swamy for Ticket#11636
            submit_by                number,                 -- Added by Swamy for Ticket#11636
            inactive_plan_flag       varchar2(30),           -- Added by Swamy for Ticket#12776
            account_type             varchar2(30)            -- Added by Swamy for Ticket#12776
    );
    type employer_details_rec_t is
        table of employer_details_rec;
----------9141  done by rprabu  on 13/08/2020  P_Account_Type added for Ticket #9440 04/09/2020
    function get_employer_details (
        p_entrp_id     in number,
        p_account_type in varchar2,
        p_source       in varchar2                -- Added by Swamy for Tiecket#11364(Broker)
    ) return employer_details_rec_t
        pipelined
        deterministic;

----------9396  done by rprabu  on 13/08/2020
    type ein_details_rec_t is
        table of enterprise%rowtype;

----------9141  done by rprabu  on 13/08/2020
    function get_ein_details (
        p_ein          in varchar2,
        p_account_type in varchar2
    ) return ein_details_rec_t
        pipelined
        deterministic;

--- added by Joshi on 10/12/2020  for Ticket#9392
    procedure insert_comp_staging (
        p_batch_number in number,
        p_entrp_id     in number,
        p_account_type in varchar2,
        p_user_id      in number
    );

-- Added by jaggi for 10430
    function is_inactive_plan_exists (
        p_ein in varchar2
    ) return varchar2;

    type accounts_row_t is record (
            entrp_code    varchar2(20),
            acc_id        number,
            acc_num       varchar2(20),
            account_type  varchar2(50),
            entrp_id      number,
            start_date    varchar2(20),
            plan_end_date varchar2(20)
    );
    type accounts_t is
        table of accounts_row_t;

-- Added by jaggi for 10430
    function get_er_inactive_plans (
        p_ein in varchar2
    ) return accounts_t
        pipelined
        deterministic;

-- Added by Joshi for 10430
    function get_resubmit_inactive_flag (
        p_entrp_id number
    ) return varchar2;

-- Added by Joshi for 10430
    procedure update_inactive_account (
        p_acc_id  number,
        p_user_id number
    );   

-- Added by Joshi for 10430
    type plan_type_rec is record (
            lookup_code varchar2(30),
            description varchar2(200)
    );
    type plan_type_rec_t is
        table of plan_type_rec;
    function get_inactive_not_enrolled_plans (
        p_acc_id number
    ) return plan_type_rec_t
        pipelined
        deterministic;

-- Added by Jaggi for 10742
    type get_amendment_plans_rec is record (
            account_type varchar2(30),
            acc_id       number(9),
            fee          number
    );
    type get_amendment_plans_rec_t is
        table of get_amendment_plans_rec;
    function get_amendment_plans (
        p_tax_id in varchar2
    ) return get_amendment_plans_rec_t
        pipelined
        deterministic;

-- Added by Swamy for Ticket#10747
    procedure update_broker_bank_stage (
        p_entrp_id     in number,
        p_batch_number in number,
        p_user_id      in number
    );

-- Added by Jaggi for Ticket #11081 & 11086
    type l_cursor is ref cursor;
    type tbl_account_pref_staging_row is record (
            acc_id           number,
            account_type     varchar2(30),
            authorize_option varchar2(255),
            descriptions     varchar2(255),
            is_authorized    varchar2(1),
            nav_code         varchar2(30)
    );
    type tbl_account_pref_staging_t is
        table of tbl_account_pref_staging_row;
    function get_acc_preference_staging (
        p_batch_number in number,
        p_entrp_id     in number,
        p_source       in varchar2
    ) return tbl_account_pref_staging_t
        pipelined;

    procedure upsert_acc_pref_staging (
        p_batch_number     in number,
        p_entrp_id         in number,
        p_authorize_option pc_broker.varchar2_tbl,
        p_is_authorized    pc_broker.varchar2_tbl,
        p_user_id          in number,
        p_source           in varchar2,
        x_error_status     out varchar2,
        x_error_message    out varchar2
    );

    procedure update_acct_pref (
        p_batch_number in number,
        p_entrp_id     in number
    );

-- Added by Jaggi #11364
    procedure update_online_compliance_staging (
        p_batch_number                in number,
        p_entrp_id                    in number,
        p_acct_fee_paid_by            in varchar2,
        p_acct_fee_payment_method     in varchar2,
        p_optional_fee_paid_by        in varchar2,
        p_optional_fee_payment_method in varchar2
    );

-- Added by Swamy for Ticket#11364
    procedure cobra_renewal_final_submit (
        p_entrp_id      in number,
        p_acc_id        in number,
        p_batch_number  in number,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

-- Added by Swamy for Ticket#11364(broker)
    procedure renewal_app_signed_by_staging (
        p_entrp_id        in number,
        p_batch_number    in number,
        p_account_type    in varchar2,
        p_sign_type       in varchar2, -----who is signing
        p_contact_name    in varchar2,
        p_email           in varchar2,
        p_renewed_by      in varchar2,
        p_renewed_user_id in number,
        x_error_status    out varchar2,
        x_error_message   out varchar2
    );

-- Added by Jaggi #11596
    procedure upsert_employer_user_staging_online (
        p_email                        in varchar2,
        p_ein_number                   in varchar2,
        p_management_account_user_name in varchar2,
        p_management_account_password  in varchar2,
        p_password_question            in varchar2,
        p_password_answer              in varchar2,
        p_enrollment_id                in number,
        x_enrollment_id                out number,
        x_error_message                out varchar2,
        x_return_status                out varchar2
    );

-- Added by Jaggi #11596
    procedure upsert_emp_company_staging (
        p_name            in varchar2,
        p_address         in varchar2,
        p_city            in varchar2,
        p_state           in varchar2,
        p_zip             in varchar2,
        p_phone           in varchar2,
        p_fax_id          in varchar2,
        p_office_phone_no in varchar2,
        p_enrollment_id   in out number,
        x_error_message   out varchar2,
        x_return_status   out varchar2
    );

-- Added by Jaggi #11596
    procedure upsert_emp_product_staging (
        p_enrollment_id in varchar2,
        p_ein_number    in varchar2,
        p_account_type  in varchar2_tbl,
        p_salesrep_flag in varchar2,
        p_salesrep_name in varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

 -- Added by Jaggi #11596
    type get_er_online_enrollment_details_row is record (
            enrollment_id                number,
            name                         varchar2(255),
            ein_number                   varchar2(255),
            address                      varchar2(255),
            city                         varchar2(255),
            state                        varchar2(255),
            zip                          varchar2(255),
            contact_name                 varchar2(255),
            phone                        varchar2(255),
            email                        varchar2(255),
            username                     varchar2(255),
            enrollment_account_user_name varchar2(255),
            password                     varchar2(255),
            enrollment_account_password  varchar2(255),
            pass_question                varchar2(255),
            pass_answer                  varchar2(255),
            entrp_id                     number,
            acc_num                      varchar2(30),
            fax_no                       varchar2(100),
            salesrep_id                  number,
            salesrep_flag                varchar2(2),
            office_phone_number          varchar2(100),
            salesrep_name                varchar2(200)
    );
    type get_er_online_enrollment_details_row_t is
        table of get_er_online_enrollment_details_row;
    function get_er_online_enrollment_details (
        p_enrollment_id in number
    ) return get_er_online_enrollment_details_row_t
        pipelined
        deterministic;

 -- Added by Jaggi #11596
    type get_er_online_product_details_row is record (
        account_type varchar2(255)
    );
    type get_er_online_product_details_row_t is
        table of get_er_online_product_details_row;
    function get_er_online_product_details (
        p_enrollment_id in number
    ) return get_er_online_product_details_row_t
        pipelined
        deterministic;

 -- Added by Jaggi #11596
    procedure process_employer_online (
        p_enrollment_id in number,
        p_enrolle_type  in varchar2 default 'E',
        p_referral_url  in varchar2,
        p_referral_code in varchar2,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

-- Added by Joshi for 12526                                     
    function get_plan_validity (
        p_batch_number number,
        p_entrp_id     number
    ) return varchar2;

-- Added by Swamy for Ticket#12534 
    procedure set_payment_cobra (
        p_entrp_id                in number,
        p_acc_id                  in number,
        p_batch_number            in number,
        p_bank_name               in varchar2,
        p_bank_acc_type           in varchar2,
        p_routing_number          in varchar2,
        p_bank_acc_num            in varchar2,
        p_bank_acct_usage         in varchar2,
        p_user_id                 in number,
        p_page_validity           in varchar2,
        p_bank_authorize          in varchar2,
        p_giac_response           in varchar2,
        p_giac_verify             in varchar2,
        p_giac_authenticate       in varchar2,
        p_bank_acct_verified      in varchar2,
        p_business_name           in varchar2,
        p_annual_optional_remit   in varchar2,
        p_fees_remitance_flag     in varchar2
                           --,p_pay_optional_fees_by        IN    VARCHAR2
                           --,p_optional_fee_payment_method IN    VARCHAR2
        ,
        p_optional_bank_authorize in varchar2,
        p_remit_bank_authorize    in varchar2,
        p_bank_acct_stg_id        in number,
        p_existing_bank_flag      in varchar2     -- Added by Swamy for Ticket#12534
        ,
        p_bank_acct_id            in number     -- Added by Swamy for Ticket#12534(12624)
        ,
        x_bank_status             out varchar2,
        x_error_status            out varchar2,
        x_error_message           out varchar2
    );

-- Added by Swamy for Ticket#12534 
    procedure upsert_compliance_staging_info (
        p_entrp_id                    in number,
        p_batch_number                in number,
        p_source                      in varchar2,
        p_fees_payment_flag           in varchar2,
        p_salesrep_flag               in varchar2,
        p_salesrep_id                 in number,
        p_cp_invoice_flag             in varchar2,
        p_fees_remitance_flag         in varchar2,
        p_acct_payment_fees           in varchar2,
        p_pay_optional_fees_by        in varchar2,
        p_optional_fee_payment_method in varchar2
                                       -- ,p_optional_fee_bank_acct_id   IN    NUMBER
                                      --  ,P_optional_Bank_Authorize     IN    VARCHAR2
                                      --  ,P_Remit_Bank_Authorize        IN    VARCHAR2
                                      --  ,P_Bank_Authorize              IN    VARCHAR2
                                       -- ,p_bank_acct_id                IN    NUMBER
        ,
        p_page_validity               in varchar2,
        p_user_id                     in number,
        x_error_status                out varchar2,
        x_error_message               out varchar2
    );
-- Added by Swamy for Ticket#12534 
    procedure insert_enroll_renew_bank_accounts (
        p_entrp_id               in number,
        p_acc_id                 in number,
        p_batch_number           in number,
        p_acct_payment_fees      in varchar2,
        p_fees_payment_flag      in varchar2,
        p_optional_fee_paid_by   in varchar2,
        p_opt_fee_payment_method in varchar2,
        p_user_id                in number,
        p_source                 in varchar2,
        p_account_status         out number,
        x_error_status           out varchar2,
        x_error_message          out varchar2
    );
-- Added by Swamy for Ticket#12534 
    function get_cobra_giact_bank_details (
        p_entrp_id     in number,
        p_batch_number in number
    ) return sys_refcursor;

-- Added by Swamy for Ticket#12534 
    procedure upsert_optional_remit_details (
        p_entrp_id                    in number,
        p_batch_number                in number,
        p_pay_optional_fees_by        in varchar2,
        p_optional_fee_payment_method in varchar2,
        p_optional_bank_authorize     in varchar2,
        p_remit_bank_authorize        in varchar2,
        p_bank_authorize              in varchar2,
        p_bank_acct_id                in number,
        x_error_status                out varchar2,
        x_error_message               out varchar2
    );

--Added by Joshi for 12621
    procedure er_add_remitt_bank_notify_request (
        p_acc_id      number,
        p_entity_type varchar2,
        p_entity_id   in number,
        p_user_id     number
    );

    procedure insert_staging_bank_giact (
        p_bank_json             in varchar2,
        p_batch_number          in varchar2,
        p_entrp_id              in number,
        p_user_id               in number,
        p_user_bank_acct_stg_id out number,
        p_bank_status           out varchar2,
        p_bank_message          out varchar2,
        x_return_status         out varchar2,
        x_error_message         out varchar2
    );

-- Added by Jaggi #12672 
    procedure upsert_cobra_service (
        p_service_type   in varchar2,
        p_acc_id         in number,
        p_ben_plan_id    in number,
        p_effective_date in date,
        p_user_id        in number,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    );

    function get_existing_bank_acct_detail (
        p_entity_type varchar2,
        p_entity_id   in number
    ) return bank_info_row_t
        pipelined
        deterministic;

--Added by Swamy for Ticket#12675(POP GIACT)
    procedure set_payment (
        p_entrp_id          in number,
        p_batch_number      in number,
        p_salesrep_flag     in online_compliance_staging.salesrep_flag%type,
        p_salesrep_id       in online_compliance_staging.salesrep_id%type,
        p_acct_payment_fees in varchar2,
        p_fees_payment_flag in varchar2,
        p_page_validity     in varchar2,
        p_user_id           in number,
        x_error_status      out varchar2,
        x_error_message     out varchar2
    );

end pc_employer_enroll_compliance;
/


-- sqlcl_snapshot {"hash":"6436c6d6a49927c2a480c717792c7b919c8bbffb","type":"PACKAGE_SPEC","name":"PC_EMPLOYER_ENROLL_COMPLIANCE","schemaName":"SAMQA","sxml":""}