-- liquibase formatted sql
-- changeset SAMQA:1754374141738 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_web_compliance.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_web_compliance.sql:null:e7b13032e3ae4793614383146f7fed85b4f6d9cd:create

create or replace package samqa.pc_web_compliance as
/*Ticket 5518 */
    type varchar2_tbl is
        table of varchar2(300) index by binary_integer;

--MAIL_TO VARCHAR2(100):='IT-Team@sterlingadministration.com';
    type rec_plan is record (
            account_type        varchar2(500),
            acc_num             varchar2(500),
            plan_year           varchar2(500),
            plan_code           varchar2(500),
            plan_name           varchar2(500),
            entrp_id            varchar2(500),
            acc_id              varchar2(500),
            effective_date      varchar2(500),
            end_date            varchar2(500),
            account_status      varchar2(500),
            emp_count           number,
            show_account_online varchar2(1),    -- Added by Swamy for Ticket#9332 on 06/11/2020
            inactive_plan_flag  varchar2(1)     -- Added  by Joshi for Ticket#10430 on 04/11/2021
    );
    type tbl_plan is
        table of rec_plan;

/*   FUNCTION GET_PLAN_DTL (P_ACC_ID IN NUMBER)
      RETURN TBL_PLAN
      PIPELINED;*/

    function get_employer_info (
        p_entrp_id   in number,
        p_entrp_code in varchar2
    ) return tbl_plan
        pipelined
        deterministic;

    type rec_ee_plan is record (
            account_type   varchar2(500),
            acc_num        varchar2(500),
            plan_year      varchar2(500),
            plan_code      varchar2(500),
            plan_name      varchar2(500),
            pers_id        varchar2(500),
            acc_id         varchar2(500),
            effective_date varchar2(500),
            end_date       varchar2(500),
            account_status varchar2(500),
            person_type    varchar2(30)      -- Added by Swamy for Ticket#9656 on 24/03/2021
    );
    type tbl_ee_plan is
        table of rec_ee_plan;
    function get_employee_info (
        p_acc_id in number,
        p_ssn    in varchar2
    ) return tbl_ee_plan
        pipelined;

    type rec_invoice is record (
            invoice_id       varchar2(500),
            invoice_reason   varchar2(500),
            invoice_date     varchar2(500),
            invoice_due_date varchar2(500),
            invoice_amount   varchar2(500),
            status           varchar2(500)
    );
    type tbl_invoice is
        table of rec_invoice;
    function get_invoice_dtl (
        p_acc_id in number
    ) return tbl_invoice
        pipelined;

    type rec_emp is record (
            acc_num    varchar2(500),
            first_name varchar2(500),
            last_name  varchar2(500)
    );
    type tbl_emp is
        table of rec_emp;

   -- Commented by Swamy for SQL Injection for Qualified Benefeciary Tab in Cobra Product. (White hat www Vid: 48289429)
   /*FUNCTION GET_COBRA_EE_LIST (P_ACC_ID IN NUMBER, P_PERSON_TYPE IN VARCHAR2)
      RETURN TBL_EMP
      PIPELINED;
   */

     -- Added by Swamy for SQL Injection for Qualified Benefeciary Tab in Cobra Product. (White hat www Vid: 48289429)
    type l_cursor is ref cursor;
    function get_cobra_ee_list (
        p_acc_id      in number,
        p_person_type in varchar2,
        p_first_name  in varchar2,
        p_last_name   in varchar2,
        p_acc_num     in varchar2,
        p_sort_column in varchar2,
        p_sort_order  in varchar2
    ) return tbl_emp
        pipelined
        deterministic;

    type rec_cob is record (
            plan_name        varchar2(500),
            year             varchar2(500),
            effective_date   varchar2(500),
            annual_election  number,
            account_balance  number,
            termination_date varchar2(500)
    );

   --  (acc_num varchar2(10),
   --  plan_name varchar2(10),
   --  effective_date varchar2(10),
   --  account_status varchar2(10));

    type tbl_cob is
        table of rec_cob;
    function get_ee_dtl (
        p_acc_num in varchar2
    ) return tbl_cob
        pipelined;

    type rec_cobra_payment is record (
            fee_date varchar2(500),
            amount   number,
            fee_name varchar2(500)
    );
    type tbl_cobra_payment is
        table of rec_cobra_payment;
    function get_cobra_payments (
        p_ssn  in varchar2,
        p_year in varchar2 default null
    ) return tbl_cobra_payment
        pipelined;

    function get_cobra_pymnts_mob (
        p_ssn in varchar2
    )                       --,
      --P_YEAR   IN  VARCHAR2)
     return tbl_cobra_payment
        pipelined;

    type rec_erisa is record (
            ben_plan_id          number,
            entity_type          varchar2(500),
            plan_code            varchar2(500),
            grandfathered        varchar2(500),
            clm_lang_in_spd      varchar2(500),
            no_of_eligible       varchar2(500),
            controlled_group     varchar2(1),
            affiliated_er        varchar2(1),
            ben_plan_number      number,
            included_plans       varchar2(500),
            no_of_employees      number,
            erissa_wrap_doc_type varchar2(1),  -- Added by Joshi for 7791(Renewal).
            note                 varchar2(4000)
    );
    type tbl_erisa is
        table of rec_erisa;
    function get_er_erisa_dtl (
        p_entrp_id in number
    ) return tbl_erisa
        pipelined;

/*   PROCEDURE UPDATE_ERISA_DTL (P_ENTRP_ID              NUMBER,
                               P_BEN_PLAN_ID           NUMBER,
                               P_ENTITY_TYPE           VARCHAR2,
                               P_NO_OF_ELIGIBLE        NUMBER,
                               P_PLAN_CODE             NUMBER,
                               P_BEN_PLAN_NUMBER       NUMBER,
                               P_GRANDFATHERED         VARCHAR2,
                               P_CLM_LANG_IN_SPD       VARCHAR2,
                               P_AFFILIATED_ER         VARCHAR2,
                               P_NOTE                  VARCHAR2,
                               X_RETURN_STATUS     OUT VARCHAR2,
                               X_ERROR_MESSAGE     OUT VARCHAR2);*/

    type rec_ben_codes is record (
            benefit_code_id   number,
            benefit_code_name varchar2(1000),
            meaning           varchar2(1000),
            eligibility       varchar2(1000),
            er_cont_pref      varchar2(1000),
            ee_cont_pref      varchar2(1000)
--      ROW_SET           VARCHAR2 (4000)
    );

   --  ELIGIBILITY VARCHAR2(100),ER_CONT_PREF VARCHAR2(100),EE_CONT_PREF VARCHAR2(100));
    type tbl_ben_codes is
        table of rec_ben_codes;
    function get_benefit_codes (
        p_entrp_id    number,
        p_ben_plan_id in number default null,
        p_lookup_name in varchar2 default null
    ) return tbl_ben_codes
        pipelined;

/*   PROCEDURE UPDATE_BEN_CODES (P_BENEFIT_CODE_ID       NUMBER,
                               P_ELIGIBILITY           VARCHAR2,
                               P_ER_CONT_PREF          VARCHAR2,
                               P_EE_CONT_PREF          VARCHAR2,
                               X_RETURN_STATUS     OUT VARCHAR2,
                               X_ERROR_MESSAGE     OUT VARCHAR2);*/

    type rec_file is record (
            file_name     varchar2(1000),
            plan_name     varchar2(500),
            attachment_id number,
            year          varchar2(500)
    );

   --   ATTACHMENT BLOB);

    type tbl_file is
        table of rec_file;
    function get_pdf_file_list (
        p_entrp_id in varchar2
    ) return tbl_file
        pipelined;

    function get_file_attachment (
        p_attachment_id number
    ) return blob;

    type rec_cobra_ee_payment is record (
            fee_date      varchar2(500),
            amount        number,
            amount_add    number,
            ee_fee_amount number,
            er_fee_amount number,
            fee_names     varchar2(500),
            fee_code      varchar2(500),
            pay_code      varchar2(500),
            cc_number     varchar2(500),
            note          varchar2(500),
            acc_id        number,
            change_num    number
    );
    type tbl_cobra_ee_payment is
        table of rec_cobra_ee_payment;

/*   FUNCTION COBRA_EE_PAYMENT (P_ACC_ID       IN NUMBER,
                              P_START_DATE   IN DATE,
                              P_END_DATE     IN DATE)
      RETURN TBL_COBRA_EE_PAYMENT
      PIPELINED;*/

    type rec_cobra_ee_detail is record (
            acc_num        varchar2(500),
            plan_name      varchar2(500),
            effective_date varchar2(500),
            account_status varchar2(500),
            contribution   number,
            period         varchar2(500)
    );
    type tbl_cobra_ee_detail is
        table of rec_cobra_ee_detail;
    function get_cobra_ee_detail (
        p_ssn in varchar2                         --,
                                                  --P_YEAR  IN  VARCHAR2
    ) return tbl_cobra_ee_detail
        pipelined;

    type rec_cobra_cont is record (
            contribution number,
            period       varchar2(500)
    );
    type tbl_cobra_cont is
        table of rec_cobra_cont;
    function get_cobra_contribution (
        p_acc_num in varchar2,
        p_year    in varchar2
    ) return tbl_cobra_cont
        pipelined;

    type rec_broker is record (
            contact_id  number,
            broker_name varchar2(500),
            email       varchar2(100),
            entity_type varchar2(20)
    );
    type tbl_broker is
        table of rec_broker;
    function get_broker_info (
        p_acc_num in varchar2
    ) return tbl_broker
        pipelined;

    function get_rate_plan_cost (
        p_entity_id      in varchar2,
        p_rate_plan_name in varchar2
    ) return varchar2;

    type rec_rate_plan_cost is record (
            rate_plan_id        number,
            rate_plan_detail_id number,
            rate_plan_name      varchar2(500),
            rate_plan_cost      varchar2(500)
    );
    type tbl_rate_plan_cost is
        table of rec_rate_plan_cost;
    function get_all_rate_plan_cost (
        p_entity_id    in varchar2,
        p_product_type varchar2
    ) return tbl_rate_plan_cost
        pipelined;

    type rec_cobra_suite is record (
            rate_plan_detail_id number,
            rate_plan_name      varchar2(100),
            min_range           varchar2(10),
            max_range           varchar2(10),
            rate_plan_cost      varchar2(10)
    );
    type tbl_cobra_suite is
        table of rec_cobra_suite;
    function get_cobra_suite (
        p_rate_plan_detail_id number,
        flg                   number default null
    ) return tbl_cobra_suite
        pipelined;

    type rec_last_renew is record (
            rate_plan_name varchar2(100),
            amount         number
    );
    type tbl_last_renew is
        table of rec_last_renew;
    function last_renew (
        p_entrp_id number
    ) return tbl_last_renew
        pipelined;

    function get_contact_info (
        p_ein varchar2
    ) return tbl_broker
        pipelined;

    type rec_broker_info is record (
            broker_id   number,
            broker_name varchar2(50),
            broker_lic  varchar2(20),
            email       varchar2(50),
            ga_id       number
    );
    type tbl_broker_info is
        table of rec_broker_info;

-- added by Jaggi #11364
    type rec_carrier_notif_stg is record (
            entrp_id              number,
            entity_id             number,
            entity_type           varchar2(100),
            plan_number           varchar2(100),
            policy_number         varchar2(100),
            cariier_name          varchar2(100),
            carrier_contact_name  varchar2(100),
            carrier_contact_email varchar2(100),
            carrier_phone_no      varchar2(100),
            carrier_addr          varchar2(1000),
            creation_date         date,
            created_by            number,
            last_update_date      date,
            last_updated_by       number,
            carrier_notify_id     number,
            batch_number          number
    );
    type tbl_carrier_notif is
        table of rec_carrier_notif_stg;
    function get_broker_info_from_ein (
        p_entrp_code varchar2
    ) return tbl_broker_info
        pipelined;

--   TYPE REC_CONTACT_INFO IS RECORD (
--      FIRST_NAME   VARCHAR2 (255),
--      BROKER_LIC   VARCHAR2 (20),
--      EMAIL        VARCHAR2 (50)
--   );

--   TYPE TBL_CONTACT_INFO IS TABLE OF REC_CONTACT_INFO;

   --   FUNCTION GET_BROKER_CONTACT(P_BROKER_ID NUMBER)RETURN TBL_CONTACT_INFO PIPELINED;

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
        x_return_status   out varchar2,
        x_error_message   out varchar2
    );

    procedure insrt_ar_quote_headers (
        p_quote_name                varchar2,
        p_quote_number              varchar2,
        p_total_quote_price         varchar2,
        p_quote_date                varchar2,
        p_payment_method            varchar2 default null,
        p_entrp_id                  number,
        p_bank_acct_id              number,
        p_ben_plan_id               number,
        p_user_id                   number,
        p_quote_source              in varchar2 default 'ONLINE',
        p_product                   in varchar2,
        p_billing_frequency         in varchar2 default 'A',       -- 8471 Joshi
        p_optional_payment_method   varchar2 default null,         -- Added by Jaggi #11262
        p_optional_fee_bank_acct_id in number default null,        -- Added by Jaggi #11262
        x_quote_header_id           out number,
        x_return_status             out varchar2,
        x_error_message             out varchar2
    );

    procedure insrt_ar_quote_lines (
        p_quote_header_id     number,
        p_rate_plan_id        number,
        p_rate_plan_detail_id number,
        p_line_list_price     number,
        p_notes               varchar2,
        p_user_id             number,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    );

    type rec_acc_num is record (
            acc_num      varchar2(20),
            acc_id       number,
            account_type varchar2(20)
    );
    type tbl_acc_num is
        table of rec_acc_num;
    function get_acc_num (
        p_entrp_code varchar2
    ) return tbl_acc_num
        pipelined;

    function get_acc_typ (
        p_invoice_id number
    ) return varchar2;

    type rec_claim_id is record (
        claim_id number
    );
    type tbl_claim_id is
        table of rec_claim_id;

   --   FUNCTION GET_CLAIM_ID(P_ACC_NUM VARCHAR2)RETURN TBL_CLAIM_ID PIPELINED;

   --FUNCTION GET_GA_LIC(P_GA_ID NUMBER)RETURN TBL_GA_LIC PIPELINED;

    function get_broker_or_ga (
        p_acc_id number
    ) return varchar2;

    procedure upsert_erisa_stage (
        p_entrp_id             number,
        p_acc_id               number,
        p_ben_plan_id          number,
        p_entity_type          varchar2,
        p_grandfathered        varchar2,
        p_clm_lang_in_spd      varchar2,
                                 /*Ticket#5518 */
        p_administered         in varchar2 default null,
        p_subsidy_in_spd_apndx in varchar2 default null,
        p_col_bargain          in varchar2 default null,
        p_ben_plan_number      number default null,
        p_no_of_eligible       number,
        p_no_of_employees      number,
        p_affiliated_er        varchar2,
        p_controlled_group     varchar2,
        p_note                 varchar2,
        p_bank_acct_num        varchar2,
        p_plan_include         varchar2,
        p_form55_opted         varchar2,
        p_erissa_erap_doc_type in varchar2 default null, -- added by Joshi for renewal(7791)
        p_fiscal_end_date      in varchar2,              -- added by Swamy for Ticket#7791
        p_user_id              number,
        p_ben_plan_name        varchar2,                 -- added by jaggi #9905
        x_return_status        out varchar2,
        x_error_message        out varchar2
    );

    procedure upsert_erisa_ben_codes (
        p_entity_id             number,
        p_benefit_code_id       number,
        p_benefit_code_name     varchar2,
        p_eligibility           varchar2,
        p_er_cont_pref          varchar2,
        p_ee_cont_pref          varchar2,
        p_contrib_lng           varchar2,  /*Ticket#5518*/
        p_refer_to_doc          varchar2,
        p_eligibility_refer_doc varchar2, -- Added by Joshi for 7791(Renewal)
        p_other_desc            varchar2,
        p_user_id               number,
        x_return_status         out varchar2,
        x_error_message         out varchar2
    );

    type post_renewal_det_rec is record (
            employer_name  varchar2(500),
            account_number varchar2(500),
            product        varchar2(500),
            eff_date       varchar2(500),
            end_date       varchar2(500),
            doc_change     varchar2(500),
            doc_update     varchar2(500),
            acc_manager    varchar2(500),
            sales_rep      varchar2(500),
            inv_to_brkr    varchar2(500),
            brkr_info_cnf  varchar2(500),
            brkr_name      varchar2(500),
            brkr_email     varchar2(500)
    );
    type post_renewals_det_tbl is
        table of post_renewal_det_rec;
    type past_renewals_det_tbl is
        table of post_renewal_det_rec;
    type post_renewals_week_det_tbl is
        table of post_renewal_det_rec;
    procedure insert_alert (
        p_subject in varchar2,
        p_message in varchar2
    );

    procedure post_renewal_details (
        p_user_id       in number default null,
        x_file_name     out varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure past_renewal_details (
        p_user_id       in number default null,
        x_file_name     out varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure post_weekly_renewal_details /*(
                                   P_USER_ID         IN  NUMBER DEFAULT NULL,
                                   X_FILE_NAME      OUT  VARCHAR2,
                                   X_ERROR_MESSAGE  OUT  VARCHAR2,
                                   X_RETURN_STATUS OUT VARCHAR2)*/;

    type rec_bank_name is record (
            flag          varchar2(1),
            bank_name     varchar2(255),
            bank_acct_num varchar2(20)
    );
    type tbl_bank_name is
        table of rec_bank_name;
    function get_bank_name (
        p_entrp_id number
    ) return tbl_bank_name
        pipelined;

    type rec_rnwl is record (
            acc_id                       number,
            acc_num                      varchar2(20),
            ben_plan_id                  number,
            product_type                 varchar2(100),
            plan_type                    varchar2(100),
            plan_name                    varchar2(100),
            plan_year                    varchar2(21),
            new_plan_year                varchar2(21),
            renewed                      varchar2(1),
            renewal_date                 varchar2(12),
            declined                     varchar2(1),
            declined_date                varchar2(12),
            ein                          varchar2(100),
            broker_id                    account.broker_id%type,  -- added by swamy for email_blast
            am_id                        account.am_id%type,        -- added by swamy for email_blast
            entrp_email                  enterprise.entrp_email%type,  -- added by swamy for email_blast
            entrp_name                   enterprise.name%type, -- added by swamy for email_blast
            tax_id                       enterprise.entrp_code%type,
            plan_end_date                date,         -- Added by swamy for email_blast
            is_renewed                   varchar2(1),   -- Added by Swamy for Ticket#9384
            renewal_deadline             date,          -- Added by Swamy for Ticket#9384
            renewal_resubmit_flag        varchar2(1),  -- Added by Swamy for Ticket#10431
            renewal_resubmit_assigned_to varchar2(10)  -- Added by jaggi for Ticket#11636
    );
    type tbl_rnwl is
        table of rec_rnwl;
    function get_er_plans (
        p_acc_id       number,
        p_product_type in varchar2 default null,
        p_tax_id       in varchar2 default null
    ) return tbl_rnwl
        pipelined;

    type rec_rnwd is record (
            flag                varchar2(500),
            dated               varchar2(500),
            renewed_ben_plan_id number,   -- Added by Swamy for Ticket#10431(Renewal Resubmit)
            batch_number        number   -- Added by Swamy for Ticket#10431(Renewal Resubmit)
    );
    type tbl_rnwd is
        table of rec_rnwd;

   -- Added by Swamy for Ticket#10431(Renewal Resubmit)
    type rec_rn is record (
            renewed_ben_plan_id number,
            batch_number        number
    );   -- 10431

    type tbl_rnw is
        table of rec_rn;
    function is_plan_renewed_already (
        p_acc_id       in number,
        p_account_type in varchar2
    ) return tbl_rnwd
        pipelined;

    function emp_plan_renewal_disp_cobra (
        p_acc_id in number
    ) return varchar2;

    function emp_plan_renewal_disp_erisa (
        p_acc_id in number
    ) return varchar2;

 /* Ticket#5020. POP renewal */
    function emp_plan_renewal_disp_pop (
        p_acc_id    in number,
        p_plan_type in varchar2
    ) return varchar2;

     /*Ticket# 7792 rprabu 09/07/2019 */
    function emp_plan_renwl_disp_form_5500 (
        p_acc_id in number
    ) return varchar2;

    procedure upload_ft_williams (
        p_file_name     in varchar2,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure upload_ft_williams_staging (
        p_user_id       in number,
        x_batch_number  out number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure send_invoice (
        p_entrp_id      number,
        p_email         varchar2,
        p_flag          varchar2,
        p_user_id       in number,
        p_ben_plan_id   in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    function get_cobra_ee_notify (
        p_acc_id number
    ) return varchar2;

    function is_plan_declined_cobra (
        p_acc_id in number
    ) return tbl_rnwd
        pipelined;

    function display_pop_renewal (
        p_acc_id in number
    ) return varchar2;

    function check_email (
        p_email varchar2
    ) return number;

    procedure update_er_account_cobra (
        p_acc_id                number,
        p_new_plan_year         varchar2,
        p_user_id               number,
        p_pay_acct_fees         varchar2,   --Renewal Phase#2  from 8471 Jagadeesh
        p_optional_fee_paid_by  varchar2,   --  added by jaggi #11262.
        p_no_of_eligible        number,
        p_authorize_req_id      number,
        p_policy_number         pc_online_enrollment.varchar2_tbl,
        p_plan_number           pc_online_enrollment.varchar2_tbl,
        p_carrier_name          pc_online_enrollment.varchar2_tbl,
        p_carrier_contact_name  pc_online_enrollment.varchar2_tbl,
        p_carrier_contact_email pc_online_enrollment.varchar2_tbl,
        p_carrier_phone_no      pc_online_enrollment.varchar2_tbl,
        p_authorize_option      pc_online_enrollment.varchar2_tbl,
        p_is_authorized         pc_online_enrollment.varchar2_tbl,
        p_nav_code              pc_online_enrollment.varchar2_tbl,
        p_staging_batch_number  in number,     -- Added by swamy for Ticket#11364
        p_source                in varchar2,  -- Added by swamy for Ticket#11364
        x_batch_number          out number,
        x_renewed_plan_id       out number,    -- Added by swamy for Ticket#11364
        x_return_status         out varchar2,
        x_error_message         out varchar2
    );

    type rec_attach_mail is record (
            dir_path   varchar2(100),
            file_name  varchar2(100),
            to_address varchar2(100),
            subject    varchar2(1000),
            message    varchar2(1000)
    );
    type tbl_attach_mail is
        table of rec_attach_mail;
    function attach_mail return tbl_attach_mail
        pipelined;

    --    PROCEDURE DAILY_RENEWAL_COBRA;
    --    PROCEDURE DAILY_RENEWAL_ERISA;
    --    PROCEDURE POP_RENEWALS;
    --    PROCEDURE PAST_DUE_RENEWALS;
  -- FUNCTION IS_POP_NDT(P_ACC_ID NUMBER)RETURN VARCHAR2;
   -- added by Jaggi #9866
    type rec_employer_plan_info is record (
            year          varchar2(500),
            ben_plan_name varchar2(100),
            plan_type     varchar2(30)
    );
    type tbl_employer_plan_info is
        table of rec_employer_plan_info;
    function get_employer_plan_info (
        p_entrp_id     in varchar2,
        p_account_type in varchar2
    ) return tbl_employer_plan_info
        pipelined;
  -- Added by Swamy for Ticket#10431(Renewal Resubmit)
    function get_resubmit_batch_number (
        p_entrp_id  in number,
        p_acc_id    in number,
        p_plan_type in varchar2
    ) return tbl_rnw
        pipelined;
  -- Added by Swamy for Ticket#10431(Renewal Resubmit)
    procedure delete_resubmit_data (
        p_acc_id              in number,
        p_entrp_id            in number,
        p_batch_number        in number,
        p_renewed_ben_plan_id in number,
        p_ben_plan_id         in number,
        p_account_type        in varchar2,
        p_eligibility_id      in number
    );

-- Added by Swamy for Ticket#11364
    procedure populate_cobra_renewal_stage (
        p_batch_number  in number,
        p_entrp_id      in number,
        p_ben_plan_id   in number,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );
-- Added by Swamy for Ticket#11364
    procedure upsert_carrier_notification_staging (
        p_entrp_id              in number,
        p_user_id               in number,
        p_policy_number         in pc_online_enrollment.varchar2_tbl,
        p_plan_number           in pc_online_enrollment.varchar2_tbl,
        p_carrier_name          in pc_online_enrollment.varchar2_tbl,
        p_carrier_contact_name  in pc_online_enrollment.varchar2_tbl,
        p_carrier_contact_email in pc_online_enrollment.varchar2_tbl,
        p_carrier_phone_no      in pc_online_enrollment.varchar2_tbl,
        p_batch_number          in number,
        x_return_status         out varchar2,
        x_error_message         out varchar2
    );

-- Added by Jaggi #11364
    function get_carrier_notification_staging (
        p_entrp_id     in number,
        p_batch_number in number
    ) return tbl_carrier_notif
        pipelined;
-- added by Jaggi #11368
    procedure populate_fsa_hra_renewal_stage (
        p_batch_number  in number,
        p_entrp_id      in number,
        p_user_id       in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

end;
/

