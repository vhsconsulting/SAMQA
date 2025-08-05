-- liquibase formatted sql
-- changeset SAMQA:1754374139384 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_office_reports.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_office_reports.sql:null:f0d9d94f68a5ae1d983813ae00ccf93804d4cae5:create

create or replace package samqa.pc_office_reports as
    type plan_type_totals is record (
            plan_type     varchar2(100),
            sum_er        number,
            sum_ee        number,
            sum_all       number,
            grant_sum_er  number,
            grant_sum_ee  number,
            grant_sum_all number
    );
    type plan_type_totals_t is
        table of plan_type_totals;
    type string_asc_arr_t is
        table of number index by varchar2(10);
    function get_contribution_type (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return clob;

    function get_claims_type (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return clob;

    function get_all_claims_json (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_start_date      in date,
        p_end_date        in date,
        p_claim_category  in varchar2 default 'ALL_CLAIMS',
        p_service_type    in varchar2 default 'ALL',
        p_product_type    in varchar2 default 'FSA'
    ) return clob;

    function get_plans_json (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return clob;

    function all_claims_report (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_start_date      in date,
        p_end_date        in date,
        p_claim_category  in varchar2 default 'ALL_CLAIMS',
        p_service_type    in varchar2 default 'ALL',
        p_product_type    in varchar2 default 'FSA'
    ) return clob;

    function get_manual_claims (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return clob;

    function get_ga_monthly_stmt (
        p_ga_id         in varchar2,
        p_account_type  in varchar2,
        p_inv_date_from in date,
        p_inv_date_to   in date
    ) return clob;

    function claims_report (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2 default 'ALL',
        p_start_date      in date,
        p_end_date        in date,
        p_division_code   in varchar2,
        p_product_type    in varchar2
    ) return clob;

   -- hari 06/19/25
    function claims_report_by_type (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2,
        p_division_code   in varchar2,
        p_service_type    in varchar2
    ) return clob;

    function get_enrolle_year_end_letter (
        p_acc_num         in varchar2,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_division_code   in varchar2
    ) return clob;

   /*
   FUNCTION CLaims_report_BY_TYPE
     (p_entrp_id        IN NUMBER
    ,p_plan_start_date IN DATE
     ,p_plan_end_date   IN DATE)       
   RETURN cLOB ;
*/

  /* TODO enter package declarations (types, exceptions, methods etc) here */
/*
 FUNCTION All_CLaims_report
     (p_entrp_id        IN NUMBER
    ,p_plan_start_date IN DATE
     ,p_plan_end_date   IN DATE)     
   RETURN cLOB;   */

    function get_fsa_balance_register (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_product_type    in varchar2
    ) return clob;

----------   20/03/2023 rprabu
    function get_enrolle_account_balance (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2,
        p_division_code   in varchar2
    ) return clob;

--- 30/05/2023
    function get_all_claims (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_report_type     in varchar2
    ) return clob;

----------   21/06/2023 rprabu

    function get_employee_info (
        p_entrp_id      in number,
        p_division_code in varchar2
    ) return clob;

----------   07/04/2023 rprabu
    function get_1099_web (
        p_acc_num in varchar2,
        p_year    in varchar2
    ) return clob;


----------   07/04/2023 rprabu
    function get_5498_web (
        p_acc_num in varchar2,
        p_year    in varchar2
    ) return clob;

----------   07/04/2023 rprabu
    function account_detail_report (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return clob;

----------   06/04/2023 rprabu
    function get_dependent (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2
    ) return clob;

-- FUNCTION get_benefit_plans (p_entrp_id IN NUMBER,p_plan_start_date IN DATE, p_plan_end_date IN DATE)
---  Return CLOB;

----------   06/04/2023 rprabu
    function get_member (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2
    ) return clob;

----------   20/03/2023 rprabu
    function get_queen_enrolle_account_balance (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2,
        p_division_code   in varchar2
    ) return clob;

-- 06/28 not required hari commenting will remove after testing 
/*
  FUNCTION get_Claims (              p_entrp_id        IN NUMBER
                                    ,p_start_date      IN DATE
                                    ,p_end_date        IN DATE
                                    ,p_plan_start_date IN DATE
                                    ,p_plan_end_date   IN DATE
                                    ,p_plan_type       IN VARCHAR2
                                    ,p_division_code   IN VARCHAR2
                             )
             RETURN cLOB   ;
*/

    function get_enrolle_balance (
        p_entrp_id        in number,
        p_start_date      in date,
        p_end_date        in date,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2,
        p_division_code   in varchar2
    ) return clob;

    function get_contribution (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return clob;

    function get_contribution_details (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return clob;

    function get_contribution_details_hra (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return clob;

    function get_suspended_card_info (
        p_entrp_id        in number,
        p_plan_type       varchar2,
        p_plan_start_date date,
        p_plan_end_date   date
    ) return clob;

    function get_contribution_details_type (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return clob;

    function get_dependent (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2,
        p_division_code   in varchar2
    ) return clob;

    function get_member_list_bill (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_plan_type       in varchar2
    ) return clob;

    function get_debit_card_swipes_info (
        p_entrp_id        in number,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_start_date      in date,
        p_end_date        in date,
        p_division_code   in varchar2
    ) return clob;

    procedure run_claim_invoice (
        p_invoice_id in number default null,
        p_output     in varchar2 default 'FTP'
    );

    procedure get_fsafinalcomprehensivendtreport (
        p_from_date in date,
        p_to_date   in date,
        p_account   in varchar2 default null
    );

    procedure get_hrafinalcomprehensivendtreport (
        p_from_date in date,
        p_to_date   in date,
        p_account   in varchar2 default null
    );

    procedure get_fsafinalndtreport (
        p_from_date in date,
        p_to_date   in date,
        p_account   in varchar2 default null
    );

    procedure get_hraprelimndtreport (
        p_from_date in date,
        p_to_date   in date,
        p_account   in varchar2 default null
    );

    procedure get_fsaprelimcomprehensivendtreport (
        p_from_date in date,
        p_to_date   in date,
        p_account   in varchar2 default null
    );

    procedure get_hrafinalndtreport (
        p_from_date in date,
        p_to_date   in date,
        p_account   in varchar2 default null
    );

    procedure get_hrapopfinalndtreport (
        p_from_date in date,
        p_to_date   in date,
        p_account   in varchar2 default null
    );

    procedure get_fsaprelimndtreport (
        p_from_date in date,
        p_to_date   in date,
        p_account   in varchar2 default null
    );

    procedure get_hracomprehensivendtreport (
        p_from_date in date,
        p_to_date   in date,
        p_account   in varchar2 default null
    );

    function get_hra_fsa_invoice (
        p_invoice_id in number
    ) return clob;

    function get_fee_invoice (
        p_invoice_id in number
    ) return clob;

    function get_erisa500_invoice (
        p_invoice_id in number
    ) return clob;

    function get_hsa_invoice (
        p_invoice_id in number,
        p_run_mode   in varchar2 default 'APEX'
    ) return clob;

    procedure run_funding_invoice (
        p_invoice_id in number default null,
        p_output     in varchar2 default 'FTP'
    );

    function get_funding_invoice (
        p_invoice_id in number
    ) return clob;

 --    FUNCTION get_plan_details
   -- (
  --   p_invoice_id IN NUMBER
  --  )
  --  RETURN CLOB;
    procedure run_hsa_invoice (
        p_invoice_id in number default null,
        p_output     in varchar2 default 'FTP'
    );

    procedure run_invoice_pdf (
        p_invoice_id in number default null,
        p_output     in varchar2 default 'FTP'
    );

    procedure run_invoice_notify (
        p_output in varchar2 default 'FTP'
    );

    procedure run_invoice_collection (
        p_output in varchar2 default 'FTP'
    );

    procedure run_invoice_poperisa5500 (
        p_invoice_id in number default null,
        p_output     in varchar2 default 'FTP'
    );

    procedure wl_hsa_ee;

    procedure wl_hsa_er;

    procedure wl_fsa_ee;

    procedure wl_fsa_er;

    procedure wl_hra_ee;

    procedure wl_hra_er;

    procedure wl_broker;

    procedure wl_claim_denial;

    procedure wl_partial_claim_denial_letters;

    procedure wl_second_letter_insufficient;

    procedure wl_last_letter_debit_card;

    procedure wl_debit_card_adj_letters;

--- 01/20/2025
    function get_hsa_quick_view_report (
        p_entrp_id      in varchar2,
        p_division_code in varchar2,
        p_month         in number,
        p_year          in number
    ) return clob;

--- 01/21/2025
    function get_spender_saver_report (
        p_entrp_id      in varchar2,
        p_division_code in varchar2,
        p_month         in number,
        p_year          in number
    ) return clob;

--- 01/22/2025
    function balance_breakdown_report (
        p_entrp_id      in varchar2,
        p_division_code in varchar2,
        p_month         in number,
        p_year          in number
    ) return clob;

--- 01/22/2025
    function contribution_disbursement_report (
        p_entrp_id      in varchar2,
        p_division_code in varchar2,
        p_month         in number,
        p_year          in number
    ) return clob;

    procedure wl_broker_welcome (
        p_broker_id in number default null,
        p_output    in varchar2 default 'FTP'
    );

    procedure wl_claim_denial_welcome (
        p_output in varchar2 default 'FTP'
    );

    procedure wl_hsa_ee_welcome (
        p_output in varchar2 default 'FTP'
    );

    procedure wl_hsa_er_welcome (
        p_output in varchar2 default 'FTP'
    );

    procedure wl_fsa_ee_welcome (
        p_output in varchar2 default 'FTP'
    );

    procedure wl_fsa_er_welcome (
        p_output in varchar2 default 'FTP'
    );

    procedure wl_partial_claim_denial_letters_welcome (
        p_claim_id in number default null,
        p_output   in varchar2 default 'FTP'
    );

    procedure wl_second_letter_insufficient_welcome (
        p_claim_id in number default null,
        p_output   in varchar2 default 'FTP'
    );

    procedure wl_debit_card_adj_letters_welcome (
        p_claim_id in number default null,
        p_output   in varchar2 default 'FTP'
    );

    procedure wl_last_letter_debit_card_welcome (
        p_claim_id in number default null,
        p_output   in varchar2 default 'FTP'
    );

end pc_office_reports;
/

