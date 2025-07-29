create or replace package samqa.pc_web_er_renewal as

-- Added by Joshi for 7762. define renewal link showing linmit.
    g_prior_days constant integer := 90;
    g_after_days constant integer := 60;
    type rec_er_dtl is record (
            acc_id           number,
            acc_num          varchar2(20),
            ben_plan_id      number,
            product_type     varchar2(30),
            plan_type        varchar2(30),
            account_type     varchar2(30), -- added by Jaggi #10729
            plan_name        varchar2(100),
            plan_year        varchar2(100),
            new_plan_year    varchar2(100),
            renewed          varchar2(1),
            renewal_date     varchar2(100),
            declined         varchar2(1),
            declined_date    varchar2(100),
            ein              varchar2(100),
            renewal_deadline date  -- Added by Swamy for Ticket#9384
    );
    type tbl_er_dtl is
        table of rec_er_dtl;
    function get_er_plans (
        p_acc_id in varchar2
    ) return tbl_er_dtl
        pipelined;

    type rec_plan_dtl is record (
            ben_plan_id                 varchar2(500),
            plan_type                   varchar2(500),
            rollover                    varchar2(500),
            min_election                varchar2(500),
            max_election                varchar2(500),
            grace_period                varchar2(500),
            grace_days                  varchar2(20),
            runout_period               varchar2(500),
            runout_term                 varchar2(500),
            funding_option              varchar2(500),
            new_hire_contrb             varchar2(500),
            non_discm_tstng             varchar2(500),
            max_irs                     varchar2(500),
            max_irs_curr                varchar2(500),
            eob_rqrd                    varchar2(500),
            plan_year                   varchar2(500),
            product_type                varchar2(500),
            new_plan_yr                 varchar2(500),
            dr_card_bal                 varchar2(500),
            enrlmnt_start               varchar2(500),
            enrlmnt_end                 varchar2(500),
      --MAX_ELECTION_LST_YR  NUMBER,
            irs_lst_yr                  number,
     -- MAX_ELECTION_NXT_YR  NUMBER,
            irs_nxt_yr                  number,
            post_tax                    varchar2(1),
            plan_docs                   varchar2(100),--For Renewal Phase#2
            update_limit_match_irs_flag varchar2(1)
    );    --- 8237 added for 18/11/2019 rprabu

    type tbl_plan_dtl is
        table of rec_plan_dtl;
    function get_plan_dtl (
        p_ben_plan_id in varchar2
    ) return tbl_plan_dtl
        pipelined;

    type irs_det_rec is record (
            amendment_id number,
            amendment    varchar2(4000),
            plan_type    varchar2(20),
            start_date   varchar2(20),
            end_date     varchar2(20)
    );
    type irs_det_dtl is
        table of irs_det_rec;
    function get_irs_amendment (
        p_plan_strt in varchar2,
        p_plan_endt in varchar2,
        p_plan_type in varchar2
    ) return irs_det_dtl
        pipelined;

    type rec_cvrg is record (
            coverage_id     varchar2(500),
            coverage_type   varchar2(500),
            annual_election varchar2(500),
            deductible      varchar2(500),
            max_rolovr_amt  varchar2(500)
    );
    type tbl_cvrg is
        table of rec_cvrg;
    type irs_doc_t is record (
            doc_id      number,
            doc_name    varchar2(300),
            irs_doc     blob,
            irs_doc_ext varchar2(300)
    );
    type irs_doc_rec_t is
        table of irs_doc_t;
    function get_irs_docs (
        p_irs_amend_id in number
    ) return irs_doc_rec_t
        pipelined
        deterministic;

    function get_coverage (
        p_ben_plan_id in varchar2
    ) return tbl_cvrg
        pipelined;

    procedure insrt_er_ben_plan_enrlmnt (
        p_ben_plan_id                 in varchar2,
        p_min_election                in varchar2 default null,
        p_max_election                in varchar2 default null,
        p_new_plan_yr                 in varchar2,
        p_new_end_plan_yr             in varchar2 default null,     -- Added by Swamy for Ticket#9932 on 07/06/2021
        p_runout_prd                  in varchar2 default null,
        p_runout_trm                  in varchar2 default null,
        p_grace                       in varchar2 default null,
        p_grace_days                  in varchar2 default null,
        p_rollover                    in varchar2 default null,
        p_funding_options             in varchar2 default null,
        p_non_discm                   in varchar2 default null,
        p_new_hire                    in varchar2 default null,
        p_eob_required                in varchar2 default null,
        p_enrlmnt_start               in varchar2 default null,
        p_enrlmnt_endt                in varchar2 default null,
        p_plan_docs                   in varchar2 default null,  ---Renewal Phase#2
        p_user_id                     in varchar2,
        p_post_tax                    in varchar2 default null,
        p_pay_acct_fees               in varchar2,--Renewal phase#2
        p_update_limit_match_irs_flag varchar2 default null,  --- 8237 18/11/2019  rprabu
        p_source                      in varchar2 default 'ONLINE', --- 8633 02/20/2020
        p_batch_number                in number, -- Added by Swamy for Ticket#10431(Renewal Resubmit)
        p_new_ben_pln_id              in out varchar2,  -- Modified from OUT to IN OUT by Swamy for Ticket#10431(Renewal Resubmit)
        x_return_status               out varchar2,
        x_error_message               out varchar2
    );

    procedure insrt_er_ben_plan_cvrg (
        p_coverage_id     in varchar2,
        p_new_ben_plan_id in varchar2,
        p_coverage_type   in varchar2,
        p_annual_election in varchar2,
        p_deductible      in varchar2,
        p_max_rolovr_amt  in varchar2,
        p_user_id         in varchar2,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    );

    procedure insert_irs_amend_det (
        p_acc_id        in number,
        p_plan_type     in varchar2,
        p_acc_deny_flag in varchar2,
        p_userid        in varchar2,
        p_irs_id        in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure insert_ben_plan_decline_det (
        p_er_ben_plan_id in number default null,
        p_acc_id         in number,
        p_lookup_code    in varchar2,
        p_deny_reason    in varchar2,
        p_deny_flag      in varchar2,
        p_userid         in varchar2,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    );

    type rec_rnwd is record (
            flag      varchar2(500),
            dated     varchar2(500),
            plan_type varchar2(30)
    );
    type tbl_rnwd is
        table of rec_rnwd;
    function is_plan_renewed_already (
        p_acc_id    in number,
        p_plan_type in varchar2
    ) return tbl_rnwd
        pipelined;

    function is_plan_renew_trn_pkg (
        p_acc_id    in number,
        p_plan_type in varchar2
    ) return tbl_rnwd
        pipelined;

    function get_renewed_ben_plan_id (
        p_acc_id    in number,
        p_plan_type in varchar2
    ) return varchar2;

    type rec_dclnd is record (
            flag      varchar2(500),
            dated     varchar2(500),
            plan_type varchar2(30)
    );
    type tbl_dclnd is
        table of rec_dclnd;
    function is_plan_declined (
        p_er_ben_plan_id in number,
        p_acc_id         in number
    ) return tbl_dclnd
        pipelined;
--   RETURN VARCHAR2;

    type irs_det is record (
            accept_decline varchar2(4000),
            irs_id         number
    );
    type irs_tbl is
        table of irs_det;
    function is_irs_amended (
        p_acc_id in number,
        p_irs_id in number
    )
                            --P_PLAN_TYPE VARCHAR2)
     return irs_tbl
        pipelined;

    function emp_plan_renewal_disp (
        p_acc_id in number
    ) return varchar2;

    function is_trn_pkg_ua1_ren_exp (
        p_plan_end_date in date,
        p_ben_plan_id   in number
    ) return varchar2;

    procedure pos_renewal_det_fsa (
        p_acc_id in number default null
    );

    procedure pos_renewal_det_hra (
        p_acc_id in number default null
    );

    type erisa_rec is record (
            entrp_id         number,
            ben_plan_id      number,
            acc_id           number,
            plan_type        varchar2(1000),
            acc_num          varchar2(1000),
            ben_plan_name    varchar2(4000),
            plan_start_date  varchar2(100),
            plan_end_date    varchar2(100),
            effective_date   varchar2(100),
            status           varchar2(100),
            no_of_eligible   number,
            entity_type      varchar2(100),
            old_entity_type  varchar2(100),
            affiliated_er    varchar2(100),
            controlled_group varchar2(100),
            ben_plan_number  number,
            plan_include     varchar2(100),
            clm_lang_in_spd  varchar2(100),
            grandfathered    varchar2(100),
            form55_opted     varchar2(100),
            broker_added     varchar2(4000),
            ga_added         varchar2(4000),
            old_ben_plan_id  number
    );

     /*Ticket#5515 */
    type benefit_code_rec is record (
            description       varchar2(1000),
            eligibility       varchar2(200),
            er_contrib        varchar2(200),
            ee_contrib        varchar2(200),
            er_ee_contrib_lng varchar2(100),
            refer_to_doc      varchar2(100)
    );
             /*Ticket#8135 */
    type benefit_code_form_5500_rec is record (
            description        varchar2(1000),
            fully_insured_flag varchar2(5),
            self_insured_flag  varchar2(5)
    );

		/*Ticket#5517*/
    type coverage_type_rec is record (
            coverage_type varchar2(1000),
            deductible    number
    );

      -- Added by Joshi for 5020. daily change report
    type pop_rec is record (
            entrp_id         number,
            ben_plan_id      number,
            acc_id           number,
            plan_type        varchar2(1000),
            acc_num          varchar2(1000),
            ben_plan_name    varchar2(4000),
            plan_start_date  varchar2(100),
            plan_end_date    varchar2(100),
            effective_date   varchar2(100),
            pop_plan_type    varchar2(255),
            status           varchar2(100),
            no_of_eligible   number,
            entity_type      varchar2(100),
            old_entity_type  varchar2(100),
            affiliated_er    varchar2(100),
            controlled_group varchar2(100),
            ben_plan_number  number,
            broker_added     varchar2(4000),
            ga_added         varchar2(4000),
            old_ben_plan_id  number
    );
    type insur_plan_rec is record (
            plan_name     varchar2(1000),
            renewal_plan  varchar2(1),
            previous_plan varchar2(1)
    );
    procedure pos_renewal_det_erisa (
        p_acc_id in number default null
    );

    --- form 5500 prabu  8135 07/11/2019
    procedure pos_renewal_det_form_5500 (
        p_acc_id in number default null
    );
       --- form 5500 prabu
    function get_census_number (
        p_entrp_id    number,
        p_census_code varchar2,
        p_ben_plan_id number
    ) return number;
         --- form 5500 prabu
    function plan_funding (
        p_plan_fund_code varchar2,
        p_plan_fund_name varchar2
    ) return varchar2;

    type cobra_rec is record (
            entrp_name         varchar2(1000),
            acc_id             number,
            acc_num            varchar2(100),
            broker_id          number,
            ga_id              number,
            broker_name        varchar2(4000),
            ga_name            varchar2(4000),
            plan_start_date    varchar2(100),
            plan_end_date      varchar2(100),
            rep_name           varchar2(4000),
            no_of_eligible     number,
            entrp_id           number,
            plan_type          varchar2(100),
            batch_number       number,
            no_of_eligible_old number,
            ben_plan_id        number
    );
    procedure pos_renewal_det_cobra (
        p_acc_id in number default null
    );

    procedure create_aca_eligibility (
        p_ben_plan_id                 in number,
        p_aca_ale_flag                in varchar2,
        p_variable_hour_flag          in varchar2,
        p_irs_lbm_flag                in varchar2,
        p_intl_msrmnt_period          in varchar2,
        p_intl_msrmnt_start_date      in varchar2,
        p_intl_admn_period            in varchar2,
        p_stblty_period               in varchar2,
           /*Ticket#5518 */
        p_fte_hrs                     in varchar2,
        p_fte_salary_msmrt_period     in varchar2,
        p_fte_hourly_msmrt_period     in varchar2,
        p_fte_other_msmrt_period      in varchar2,
        p_fte_other_ee_name           in varchar2,
        /*--LookkBack Method */
        p_fte_look_back               in varchar2,
        p_fte_lkp_salary_msmrt_period in varchar2,
        p_fte_lkp_hourly_msmrt_period in varchar2,
        p_fte_lkp_other_msmrt_period  in varchar2,
        p_fte_lkp_other_ee_name       in varchar2,
	/*Lookback end */
        p_msrmnt_period               in varchar2,
        p_msrmnt_start_date           in varchar2,
        p_msrmnt_end_date             in varchar2,
        p_stblt_start_date            in varchar2,
        p_stblt_period                in varchar2,
        p_stblt_end_date              in varchar2,
        p_fte_same_period_resume_date in varchar2,
        p_fte_diff_period_resume_date in varchar2,
          /*Ticket#5518 */
        p_admn_start_date             in varchar2,
        p_admn_period                 in varchar2,
        p_admn_end_date               in varchar2,
        p_mnthl_msrmnt_flag           in varchar2,
        p_same_prd_bnft_start_date    in varchar2,
        p_new_prd_bnft_start_date     in varchar2,
        p_user_id                     in number,
        p_entrp_id                    in number,
        p_fte_same_period_select      in varchar2 default null,  -- Added by swamy for Ticket#6228
        p_fte_diff_period_select      in varchar2 default null,  --  Added by swamy for Ticket#6228
        p_define_intl_msrmnt_period   in varchar2 default null,  --  Added by swamy for Ticket#8684
        x_error_status                out varchar2,
        x_error_message               out varchar2
    );

    procedure process_renewal_staging (
        p_batch_num                      in number,
        p_entrp_id                       in number,
        p_user_id                        in number,
        p_pay_acct_fees                  in varchar2,
        p_invoice_flag                   in varchar2,
        p_bank_name                      in varchar2,
        p_routing_num                    in varchar2,
        p_account_type                   in varchar2,
        p_account_num                    in varchar2,
        p_fund_option                    in varchar2,
        p_bank_authorize                 in varchar2,              -- Added by Jaggi ##9602
        p_payment_method                 in varchar2,     -- Added by Swamy for Ticket#1119
        p_bank_name_monthly              in varchar2,    -- Added by Jaggi #11263
        p_routing_num_monthly            in varchar2,    -- Added by Jaggi #11263
        p_account_type_monthly           in varchar2,    -- Added by Jaggi #11263
        p_account_num_monthly            in varchar2,    -- Added by Jaggi #11263
        p_pay_monthly_fees_by            in varchar2,    -- Added by Jaggi #11263
        p_monthly_fee_payment_method     in varchar2,    -- Added by Jaggi #11263
        p_giac_response                  in varchar2,   -- Added by Swamy for Ticket#12309 
        p_giac_verify                    in varchar2,   -- Added by Swamy for Ticket#12309 
        p_giac_authenticate              in varchar2,   -- Added by Swamy for Ticket#12309 
        p_bank_acct_verified             in varchar2,   -- Added by Swamy for Ticket#12309 
        p_business_name                  in varchar2,   -- Added by Swamy for Ticket#12309 
        p_bank_status                    in varchar2,   -- Added by Swamy for Ticket#12309 
        p_giac_response_monthly          in varchar2,   -- Added by Swamy for Ticket#12309 
        p_giac_verify_monthly            in varchar2,   -- Added by Swamy for Ticket#12309 
        p_giac_authenticate_monthly      in varchar2,   -- Added by Swamy for Ticket#12309 
        p_bank_acct_verified_monthly     in varchar2,   -- Added by Swamy for Ticket#12309 
        p_business_name_monthly          in varchar2,   -- Added by Swamy for Ticket#12309 
        p_bank_status_monthly            in varchar2,   -- Added by Swamy for Ticket#12309 
        p_giac_verified_response         in varchar2,   -- Added by Swamy for Ticket#12309 
        p_giac_verified_response_monthly in varchar2,   -- Added by Swamy for Ticket#12309 
        x_enrollment_id                  out number,
        x_error_status                   out varchar2,
        x_error_message                  out varchar2
    );

/* Ticket#5020 POP Renewal reconstruction */
    procedure populate_renewal_data (
        p_batch_number in number,
        p_entrp_id     in number,
        p_plan_id      in number,
        p_user_id      in number
    );

    procedure pos_renewal_det_pop (
        p_acc_id in number default null
    ); -- #5020: by Joshi DAily changes Renewal report.

 -- Added by Swamy for Ticket#8684 on 19/05/2020
 -- Procedure to load data from staging to base tables when SUBMIT buttion from online is pressed.
    procedure erisa_renewal_final_submit (
        p_batch_number  in number,
        p_entrp_id      in number,
        p_account_type  in varchar2,
        p_user_id       in varchar2,
        p_source        in varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

-- Added by swamy for Ticket#8684 on 19/05/2020
    procedure upsert_compliance_plan_staging (
        p_entrp_id            in number,
        p_plan_number         in varchar2,
        p_plan_type           in varchar2,
        p_plan_start_date     in varchar2,
        p_plan_end_date       in varchar2,
        p_user_id             in number,
        p_page_validity       in varchar2,
        p_batch_number        in number,
        p_plan_id             in number,
        p_ben_plan_id         in number,
        p_ben_plan_name       in varchar2,    -- Added by Jaggi #9905
        p_renewed_ben_plan_id in number,   -- Added by Swamy for Ticket#10431(Renewal Resubmit)
        x_error_status        out varchar2,
        x_error_message       out varchar2
    );

-- Added by Jaggi for Ticket#8684 on 14/05/2020
    type payment_row_t is record (
            bank_name         varchar2(100),
            routing_number    varchar2(100),
            bank_acc_num      varchar2(20),
            bank_acc_type     varchar2(100),
            remittance_flag   varchar2(2),
            fees_payment_flag varchar2(10),
            salesrep_id       number,
            salesrep_flag     varchar2(2),
            send_invoice      varchar2(14),
            total_cost        number,
            acct_payment_fees varchar2(100),
            page_validity     varchar2(1),
            bank_authorize    varchar2(1)        -- Added by Jaggi ##9602
    );
    type payment_t is
        table of payment_row_t;

-- Added by Jaggi for Ticket#8684 on 14/05/2020
    function get_payment_details (
        p_batch_number in number,
        p_entrp_id     in number
    ) return payment_t
        pipelined
        deterministic;

-- Added by Jaggi for Ticket#8684 on 14/05/2020
    type employer_info_row_t is record (
            state_of_org         varchar2(100),
            fiscal_yr_end        varchar2(100),
            type_of_entity       varchar2(100),
            entity_name_desc     varchar2(100),
            affliated_flag       varchar2(2),
            cntrl_grp_flag       varchar2(2),
            plan_id              number,
            plan_type            varchar2(100),
            takeover_flag        varchar2(100),
            plan_number          varchar2(100),
            plan_start_date      varchar2(100),
            plan_end_date        varchar2(100),
            short_plan_yr_flag   varchar2(100),
            flg_plan_name        varchar2(1),
            flg_pre_adop_pln     varchar2(100),
            plan_name            varchar2(100),
            org_eff_date         varchar2(100),
            effective_date       varchar2(100),
            eff_date_sterling    varchar2(100),
            no_of_eligible       varchar2(100),
            no_off_ees           number,
            erissa_erap_doc_type varchar2(1),
            total_cost           number
    );
    type employer_info_t is
        table of employer_info_row_t;

-- Added by Jaggi for Ticket#8684 on 14/05/2020
    function get_employer_info (
        p_batch_number in number,
        p_entrp_id     in number
    ) return employer_info_t
        pipelined
        deterministic;

-- Added by Jaggi for Ticket#8684 on 14/05/2020
    type contact_leads_row_t is record (
            first_name      varchar2(100),
            job_title       varchar2(100),
            phone_num       varchar2(100),
            contact_fax     varchar2(100),
            email           varchar2(100),
            contact_type    varchar2(100),
            contact_id      number,
            lic_number      varchar2(100),
            contact_flg     varchar2(1),
            lic_number_flag varchar2(10),
            prefetched_flg  varchar2(10),
            validity        varchar2(20),
            ref_entity_type varchar2(20)
    );
    type contact_leads_t is
        table of contact_leads_row_t;

-- Added by Jaggi for Ticket#8684 on 14/05/2020
    function get_contact_leads (
        p_entrp_id     in number,
        p_account_type varchar2,
        p_contact_type varchar2
    ) return contact_leads_t
        pipelined
        deterministic;

-- Added by Swamy for Ticket#8684 on 19/05/2020
    procedure upsert_entrp_demographics (
        p_batch_number  in varchar2,
        p_entrp_id      in number,
        p_state_of_org  in varchar2,
        p_zip           in varchar2,
        p_city          in varchar2,
        p_address       in varchar2,
        p_user_id       in varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

-- Added by Swamy for Ticket#8684 on 19/05/2020
    procedure upsert_contact_leads (
        p_entrp_id      in number,
        p_user_id       in varchar2,
        p_ben_plan_id   in number,
        p_account_type  in varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

-- Added by Swamy for Ticket#9304 on 21/07/2020
    procedure populate_erisa_renewal_stage (
        p_batch_number  in number,
        p_entrp_id      in number,
        p_ben_plan_id   in number,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

    type rec_er_plan is record (
            lookup_code varchar2(100),
            description varchar2(100)
    );
    type rec_acct_fee_dtl is record (
            acc_id            number,
            account_type      varchar2(30),
            er_name           varchar2(100),
            acct_payment_fees varchar2(100)
    );
    type tbl_acct_fee_dtl is
        table of rec_acct_fee_dtl;

-- Added by Swamy for Ticket#10751
    type tbl_er_plan is
        table of rec_er_plan;
    function get_renewal_plans (
        p_acc_id in varchar2
    ) return tbl_er_plan
        pipelined;

-- added by jaggi #10743
    procedure update_fiscal_yr_enddate (
        p_entrp_id     in number,
        p_batch_number in number
    );

-- Added by Swamy for Ticket#11636 on 28/06/2023
    function get_contact (
        p_entrp_id     in number,
        p_account_type varchar2,
        p_contact_type varchar2
    ) return contact_leads_t
        pipelined
        deterministic;

   -- Added by Swamy for Ticket#11636 on 28/06/2023
    function get_acct_fee_details (
        p_entrp_id     in number,
        p_account_type varchar2,
        p_batch_number number
    ) return tbl_acct_fee_dtl
        pipelined
        deterministic;

-- Added by Joshi for ticket 12003 
    function get_plan_end_date_for_trn_pkg (
        p_acc_id    in varchar2,
        p_plan_type varchar2
    ) return date;

end pc_web_er_renewal;
/


-- sqlcl_snapshot {"hash":"70f9fa4e0aa923a91e3b9038018de1a354769703","type":"PACKAGE_SPEC","name":"PC_WEB_ER_RENEWAL","schemaName":"SAMQA","sxml":""}