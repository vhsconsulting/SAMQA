-- liquibase formatted sql
-- changeset SAMQA:1754374139975 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_reports.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_reports.sql:null:ac1416b786492fd2f8c17b7570a2cd2f53d9d83c:create

create or replace package samqa.pc_reports as

  /* TODO enter package declarations (types, exceptions, methods etc) here */

---- FUNCTION get_New_Hire_report(p_Tax_id  in Varchar2, p_Acc_num  in Varchar2,  p_Er_name  in Varchar2)      RETURN SYS_REFCURSOR

    function get_last_payment_info (
        p_entrp_id   in number,
        p_start_date varchar2,
        p_end_date   varchar2
    ) return sys_refcursor;

    function get_qb_plan_info (
        p_entrp_id   in number,
        p_start_date varchar2,
        p_end_date   varchar2
    ) return sys_refcursor;

    function get_qb_member_info (
        p_entrp_id         in number,
        p_event_start_date varchar2,
        p_event_end_date   varchar2
    ) return sys_refcursor;

    function get_plan_rate_renewal_report (
        p_entrp_id in number
    ) return sys_refcursor;

    function get_new_hire_report (
        p_entrp_id           in number,
        p_process_start_date varchar2,
        p_process_end_date   varchar2
    ) return sys_refcursor;
 --FUNCTION Get_Paid_through_Report ( p_entrp_id   in Number )  RETURN SYS_REFCURSOR ;
    function get_paid_through_report (
        p_entrp_id   in number,
        p_start_date varchar2,
        p_end_date   varchar2
    ) return sys_refcursor;

    function plan_status (
        p_plan_type in varchar2,
        p_pers_id   in number
    ) return varchar2;

    function get_generated_letters_detail_report (
        p_entrp_id in number
    ) return sys_refcursor;

    function get_generated_letters_summary_report (
        p_entrp_id in number
    ) return sys_refcursor;

    function get_carrier_notifications_report (
        p_entrp_id in number
    ) return sys_refcursor;

    function get_ben_plan_report (
        p_entrp_id        in number,
        p_plan_start_date date,
        p_end_date        date
    ) return sys_refcursor;

    function get_client_by_postal_code_report (
        p_entrp_id in varchar2,
        p_er_name  in varchar2
    ) return sys_refcursor;

    function get_qb_plan_members (
        p_acc_num          in varchar2,
        p_event_start_date varchar2,
        p_event_end_date   varchar2
    ) return sys_refcursor;

    function get_qb_summary_report (
        p_entrp_id   in number,
        p_start_date varchar2,
        p_end_date   varchar2,
        p_status     varchar2
    ) return sys_refcursor;

    function get_paid_through_date (
        p_entrp_id in number,
        p_status   in varchar2
    ) return clob;

 -- Added by Swamy for Cobra NEw Disbursement Report
    function get_disbursement_report (
        p_entrp_id in number
    ) return clob;

 -- Added by Swamy for Cobra NEw Disbursement Report
    function get_cobra_disbursement_details (
        p_entrp_id        in number,
        p_start_date      in date,
        p_end_date        in date,
        p_disbursement_id in number
    ) return clob;

 --- rpu plan rate report 19/10/22
    function get_plan_renewal_rates (
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    ) return clob;

 --- rpu plan rate report 19/10/22

    function count_plan_records (
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    ) return number;

    -- Added by Swamy for Cobra NEw Disbursement Report
    function get_disbursement_details (
        p_entrp_id        in number,
        p_disbursement_id in number
    ) return clob;

 -- Added by Swamy for Cobra NEw Disbursement Report
/*  PROCEDURE disbursement_report_blob(
    p_entrp_id             IN NUMBER
   ,p_disbursement_id      IN NUMBER
  ) ;

*/
    function get_disb_details (
        p_disbursement_id in number
    ) return clob;

    function get_npm (
        p_entrp_id           in number,
        p_process_start_date varchar2,
        p_process_end_date   varchar2
    ) return clob;

    function get_qb_summary_clob (
        p_pers_id in number,
        p_status  in varchar2
    ) return clob;

    function get_qb_summary (
        p_pers_id in number,
        p_status  in varchar2
    ) return clob;

    function get_qb_summary_by_entrp (
        p_entrp_id   in number,
        p_status     in varchar2 default 'E:P:PR:TE',
        p_start_date in date,
        p_end_date   in date
    ) return clob;
-- Added by Swamy 30jan2023 for Cobra NEw Disbursement Report which is called from PHP 
-- This procedure will get the data in JSON format using entrp id. This JSON is then used to generate report with report template stored in APEX  static application files. 
-- and then convert it into blob and store it into a table.
    function disbursement_report_blob (
        p_entrp_id        in number,
        p_disbursement_id in number
    ) return blob;

    function get_wex_disbursement_clob (
        p_cobra_disbursement_id in number
    ) return clob;

    function get_qb_payments_clob (
        p_employer   in number,
        p_status     in varchar2 default 'E:P:PR:TP:TE',
        p_start_date in date,
        p_end_date   in date
    ) return clob;

end pc_reports;
/

