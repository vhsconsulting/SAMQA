create or replace package samqa.pc_notifications is
    mail_to varchar2(100) := 'IT-Team@sterlingadministration.com';
    type varchar2_tbl is
        table of varchar2(3200) index by binary_integer; -- added by Joshi #5024

    type email_row_t is record (
        email varchar2(2000)
    );
    type claim_deny_row_t is record (
            entity_id           number,
            acc_num             varchar2(30),
            event_id            number,
            employer_name       varchar2(255),
            claim_amount        varchar2(30),
            deductible_amount   varchar2(30),
            denied_amount       varchar2(30),
            claim_pending       varchar2(30),
            claim_paid          varchar2(30),
            claim_id            varchar2(30),
            person_name         varchar2(255),
            denied_reason       varchar2(255),
            claim_status        varchar2(255),
            event_name          varchar2(255),
            address             varchar2(255),
            address2            varchar2(255),
            reviewed_date       varchar2(30),
            service_start_date  varchar2(30),
            prov_name           varchar2(255),
            source_claim_id     varchar2(30),
            source_prov_name    varchar2(255),
            source_service_date varchar2(30),
            source_claim_amount varchar2(30)
    );
    type notify_row_t is record (
            email       varchar2(255),
            email_body  varchar2(3200),
            subject     varchar2(255),
            pers_id     number,
            acc_id      number,
            entrp_id    number,
            person_name varchar2(255),
            user_name   varchar2(255),
            plan_types  varchar2(255),
            status      varchar2(255),
            acc_num     varchar2(255),
            ein         varchar2(255)
    );
    type notification_rec is record (
            user_id           number,
            notification_id   number,
            from_address      varchar2(3200),
            to_address        varchar2(3200),
            subject           varchar2(255),
            message_body      varchar2(4000),
            status            varchar2(255),
            template_name     varchar2(255),
            entity_id         number,
            notification_date date,
            invoice_notify_id number,
            account_type      varchar2(255)
    );
    type notify_t is
        table of notify_row_t;
    type claim_deny_t is
        table of claim_deny_row_t;
    type notification_t is
        table of notification_rec;
    type email_tbl_t is
        table of email_row_t;
    type number_tbl is
        table of number index by pls_integer;
    function get_email (
        p_email in varchar2
    ) return email_tbl_t
        pipelined
        deterministic;

    procedure insert_notifications (
        p_from_address    in varchar2,
        p_to_address      in varchar2,
        p_cc_address      in varchar2,
        p_subject         in varchar2,
        p_message_body    in varchar2,
        p_user_id         in number,
        p_acc_id          in number default null,
        x_notification_id out number
    );

    procedure insert_event_notifications (
        p_event_name    in varchar2,
        p_event_type    in varchar2,
        p_event_desc    in varchar2,
        p_entity_type   in varchar2,
        p_entity_id     in varchar2,
        p_acc_id        in number,
        p_acc_num       in varchar2,
        p_pers_id       in number,
        p_user_id       in number,
        p_email         in varchar2,
        p_template_name in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure set_token (
        p_token    in varchar2,
        p_string   in varchar2,
        p_notif_id in number
    );

    procedure update_notification_status (
        p_notification_id in number,
        p_status          in varchar2
    );

  -- Claim Audit

    procedure audit_review_notification (
        p_payment_register_id in number,
        p_template_name       in varchar2,
        p_user_id             in number
    );

    procedure claim_notification (
        p_payment_register_id in number,
        p_user_id             in number
    );

  -- Close Account
    procedure close_account_notification (
        p_person_name   in varchar2,
        p_acc_id        in number,
        p_provider_name in varchar2,
        p_email         in varchar2,
        p_claim_type    in varchar2,
        p_user_id       in number
    );

    procedure ach_terminated_ee_notification (
        p_person_name   in varchar2,
        p_acc_id        in number,
        p_transfer_date in varchar2,
        p_email         in varchar2,
        p_template_name in varchar2,
        p_user_id       in number
    );

    procedure insert_deny_claim_events (
        p_claim_id in number,
        p_user_id  in number
    );

    procedure get_template_body (
        p_template_name in varchar2,
        x_subject       out varchar2,
        x_template_body out varchar2,
        x_cc_address    out varchar2,
        x_to_address    out varchar2
    );

    procedure process_deny_notification;

  /*** Benefit plan renewal ***/
    procedure plan_renewal_notification;

    procedure non_discrim_notification;

    procedure send_email_on_ofac_results;

    procedure send_email_on_id_results;

    procedure send_email_duplicate_epayment;

    procedure suspended_60days_notification;

    procedure catchup_55_notification;

    procedure send_email_hra_fsa_renewal;

    procedure closed_account_reactivation;

    procedure email_hrafsa_address_error;

    procedure email_hrafsa_dep_card_error;

    procedure email_hrafsa_payment_error;

    procedure email_hrafsa_receipt_error;

    procedure email_hsa_address_error;

    procedure email_hsa_dep_card_error;

    procedure email_hsa_payment_error;

    procedure email_hsa_receipt_error;

    procedure email_annual_election_error;

    procedure email_hrafsa_bal_diff_error;

    procedure send_nightly_notification;

    procedure employer_setup_fee;

    procedure email_hrafsa_deductible;

    procedure email_hrafsa_enrollments;

    procedure notify_er_check_posted;

    procedure notify_hsa_ee_incomplete;

    procedure email_hsa_incomplete_accounts;

    procedure email_online_incomplete_app;

    procedure email_closed_opportunities;

    procedure email_sales_leads;

    procedure email_duplicate_claims;

    procedure email_sf_ord_exp_rep;

    procedure insert_inactive_bank_event (
        p_bank_acct_id in number,
        p_user_id      in number,
        p_account_type in varchar2
    );

    procedure sfo_letter_notification (
        p_pers_id     in number,
        p_acc_id      in number,
        p_letter_type in varchar2,
        p_user_id     in number
    );

    procedure process_sfo_notifications;

    function get_dept_email (
        p_dept_id in varchar2
    ) return varchar2;

    procedure email_enrollment_report;

    procedure email_er_enrollment_report;

    procedure email_ach_not_released;

    procedure email_sam_report;

    procedure ach_duplicate_report;

    procedure enrollments_audit_report;

    procedure send_email_on_5498;

    procedure email_renewal_report;

    procedure hrafsa_negative_balance_report;

    procedure hrafsa_approval_report;

    procedure send_email_on_bellarmine;

    procedure hrafsa_future_claim_notify (
        p_claim_id in number
    );

    procedure hsa_nsf_letter_notification (
        p_claim_id    in number,
        p_letter_type in varchar2,
        p_user_id     in number
    );

    procedure debit_letter_notification (
        p_pers_id     in number,
        p_acc_id      in number,
        p_letter_type in varchar2,
        p_user_id     in number,
        p_claim_id    in number
    );

    procedure insert_deny_debit_claim_event (
        p_claim_id   in number,
        p_event_name in varchar2,
        p_user_id    in number
    );

    procedure email_unsubstantiated_txn;

    procedure send_email_on_payment_diff;

    procedure send_email_on_amount_2500;

    procedure send_email_on_check_diff;

    procedure notify_claim_after_plan_yr;

    procedure notify_claim_before_plan_yr;

    procedure notify_service_after_plan_yr;

    procedure notify_no_plan_yr;

    procedure notify_takeover;

    procedure notify_see_change_er_details;

    procedure notify_fraud;

    procedure email_rate_plan_details;

    procedure email_invoice_report_details;

    procedure email_void_invoice_report;

    procedure email_sf_ord_term_rep;

    procedure email_suspended_cards;

    procedure email_multi_product_client;

    procedure email_hsa_enrollment_numbers;

    procedure email_fsa_new_enrollments;

    procedure email_fsa_enrollment_numbers;

    procedure email_hra_new_enrollments;

    procedure email_hra_enrollment_numbers;

    procedure email_pop_renewals_details;

    procedure catchup_65_notification;

    procedure compliance_payment_report;

    procedure hrafsa_ae_change_report;

    procedure email_fsa_ee_with_cobra;

    function get_claim_deny_letter return claim_deny_t
        pipelined
        deterministic;

    procedure notify_eob_claims;

    procedure notify_comp_discrim_testing;
  -- PROCEDURE process_new_ben_plans;
   --PROCEDURE process_qe_approval;
    procedure list_pending_claims;

   -- Used for sending content for all the invoice notifications
    function get_invoice_notifications (
        p_invoice_id     in number,
        p_invoice_reason in varchar2,
        p_template_name  in varchar2,
        p_notify_type    in varchar2
    ) return notify_t
        pipelined
        deterministic;

    procedure add_notify_users (
        p_user_id         in number_tbl,
        p_notification_id in number
    );

    function get_message_center (
        p_user_id in number,
        p_acc_id  number default null
    ) return notification_t
        pipelined
        deterministic;

    function get_message_body (
        p_notification_id in number
    ) return notification_t
        pipelined
        deterministic;

    procedure update_notif_participants (
        p_notification_id in number,
        p_user_id         in varchar2,
        p_status          in varchar2
    );

    procedure delete_notif_participants (
        p_notification_id in number,
        p_user_id         in varchar2
    );

    procedure insert_web_notification (
        p_from_address in varchar2,
        p_to_address   in varchar2,
        p_subject      in varchar2,
        p_message_body in varchar2,
        p_user_id      in number,
        p_acc_id       in number
    );

    procedure insert_web_notification (
        p_from_address in varchar2,
        p_to_address   in varchar2,
        p_subject      in varchar2,
        p_message_body in varchar2,
        p_user_id      in number,
        p_acc_id       in number,
        p_event        in varchar2,
        p_batch_num    in varchar2
    );

 --  procedure hsa_oversubscribe_notification(p_acc_id number,p_year varchar2 default to_char(sysdate,'rr'));
 --  procedure notify_hsa_oversubscribed(p_year varchar2 default to_char(sysdate,'rr'));

    procedure set_token_subject (
        p_token    in varchar2,
        p_string   in varchar2,
        p_notif_id in number
    );

    --OVERLOADED FOR INSERTING EVENT INSERTION
    procedure insert_notifications (
        p_from_address    in varchar2,
        p_to_address      in varchar2,
        p_cc_address      in varchar2,
        p_subject         in varchar2,
        p_message_body    in varchar2,
        p_user_id         in number,
        p_event           in varchar2,
        p_acc_id          in number default null,
        x_notification_id out number
    );

    procedure notify_er_hra_fsa_plan_renew (
        p_acc_id       in varchar2,
        p_plan_type    in varchar2,
        p_acc_num      in varchar2,
        p_ben_plan_id  in varchar2,
        p_product_type in varchar2,
        p_user_id      in varchar2,
        p_entrp_id     in varchar2
    );

    procedure notify_er_ren_decl_plan (
        p_acc_id       in varchar2,
        p_ename        in varchar2,
        p_email        in varchar2,
        p_user_id      in varchar2,
        p_entrp_id     in varchar2,
        p_ben_plan_id  in varchar2,
        p_ben_pln_name in varchar2,
        p_ren_dec_flg  in varchar2,
        p_acc_num      in varchar2
                              --    P_PAY_ACCT_FEES IN VARCHAR2 DEFAULT NULL
    );

    procedure erisa_renewal_notice;

    procedure cobra_renewal_notice;

    procedure notify_plan_document_upload (
        p_file_name   in varchar2,
        p_user_id     in number,
        p_entity_name in varchar2,
        p_entity_id   in varchar2
    );

    procedure notify_er_generate_invoice (
        p_invoice_id in number
    );

    procedure notify_cobra_receipts (
        p_acc_id number
    );

    procedure notify_pending_approvals;

    procedure notify_acct_termination;

    procedure insert_reports (
        p_report_name        in varchar2,
        p_report_dir         in varchar2,
        p_file_name          in varchar2,
        p_file_action        in varchar2,
        p_report_description in varchar2
    );

    procedure notify_er_hsa_verified (
        p_acc_id varchar2
    );

   -- Vanitha: 23-Oct-2016: Pay what we invoice enhancements
    procedure claim_invoice_refund_notify (
        p_invoice_id in number,
        p_claim_ids  in varchar2,
        p_acc_id     in number,
        p_entrp_id   in number
    );

    procedure email_partially_paid_claim_inv (
        p_invoice_id in number
    );
   -- end of Pay what we invoice enhancements

   -- Employer enrollment move 01/14/2017
    procedure daily_new_er_invoice;

    procedure daily_completed_employer;

    procedure daily_online_er_regn;
   -- Employer enrollment move 01/14/2017
    procedure hra_employer_balances;

    procedure closed_hsa_account_balances;

    procedure fsa_employer_balances;

    procedure notify_approved_claims; /*Ticket 4286 .Added on 20/09/2017 */
    procedure insert_approved_claim_events (
        p_claim_id in number,
        p_user_id  in number
    );



   /** Enrollment  Reports  ***/
    procedure daily_renewal_cobra;

    procedure daily_renewal_erisa;

    procedure pop_renewals;

    procedure past_due_renewals;
     -- Daily COBRA Renewal reports to Intake for Invoice Purposes
    procedure daily_online_renewal_inv_cobra;
    -- Daily ERISA Renewal reports to Intake for Invoice Purposes

    procedure daily_online_renewal_inv_erisa;

    procedure webform_er_daily_notfication; -- Added for webform notificaion.
     -- Added by Joshi fort 5024/5164.
    procedure send_uploadfile_notify (
        p_account_type varchar2,
        p_acc_num      varchar2,
        p_file_names   varchar2_tbl,
        p_broker_id    number
    ); -- Added for #5024

-----------------------Added by rprabu 7792 ----------------------Shedule A document upoad procedure... ------------------
    procedure upload_schedulea_notify (
        p_ben_plan_id     in number,
        p_acc_num         in varchar2,
        p_entrp_id        in number,
        p_notification_id out number
    );

/** Invoice by Division Reports ***/

    procedure email_division_rate_plan_setup (
        p_entrp_id in number
    );

    procedure inactive_banks_invoice_setup;

    procedure email_er_division_no_ees;
    /** Invoice by Division Reports ***/

    g_hsa_email varchar2(255) := 'dana.ramos@sterlingadministration.com';
    g_hrafsa_cc_email varchar2(255) := 'benefits@sterlingadministration.com';
    g_cc_email varchar2(255) := 'techlog@sterlingadministration.com,shavee.kapoor@sterlingadministration.com';
    g_nondiscrim_email constant varchar2(255) := 'sarah.soman@sterlingadministration.com,michelle.emblem@sterlingadministration.com';
    g_html_message varchar2(3200) := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Sterling Administration</title>
<style type="text/css">
<!--
.style1 { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 14px;}
.style2 { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 9px; color: #666666;}
.main { padding: 20px;}
.header { padding-right: 40px; padding-left: 40px;}
.bold { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 16px; color: #000000; font-weight: bold;}
.bold2 { font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 14px; color: #000000; font-weight: bold;}
a { color: #333333; text-decoration: underline;}
caption {font-size: 12pt; font-variant:small-caps; font-weight:bold; background: #DBE8F2; }
table { margin: 0; padding: 0;}
table th { border: 1px solid #dbe8f2; padding: 0; font-size: 11pt; font-variant:small-caps; background: #DBE8F2; text-align:center; vertical-align:bottom;}
table td { border: 1px solid #dbe8f2; padding: 0; font-size: 11pt; font-variant:small-caps; text-align:center; vertical-align:bottom;}
table td.name { text-align: left; }
-->
</style>
</head>
<body>
<div class="main">
<div align="center"><a href="http://www.sterlinghsa.com/"><img src="http://www.sterlinghsa.com/images/sterling-logo.png" align="left" border="0"></a></div>
</br>
<div style="clear:both"></div>
<div style="clear:both"></div>
XXXBODYXXX
</br>
<div align="left" class="style2" style="clear:both">'
                                     || replace(
        unistr('%\00A9%'),
        '%'
    )
                                     || to_char(sysdate, 'YYYY')
                                     || ' Sterling HSA. All rights reserved.</div>
</div>
</body>
</html>';

/*Ticket#5027 */
    procedure renewal_email_notifications (
        p_account_type in varchar2,
        p_user_id      in number
    );


/*Ticket#5335 */
    procedure send_emails_inv_not_generated;

-- Added below code by Joshi for PPP
    procedure send_schedule_confirm_email (
        p_ein     in number,
        p_acc_id  in number,
        p_user_id in number
    );

    procedure send_scheduler_remind_email;

    procedure daily_schedule_contrib_report;

    procedure daily_online_renewal_inv_pop; /*Ticket#5020 */
-- Added by Joshi for 6796
    procedure send_ameritrade_confirm_email (
        p_acc_id  in number,
        p_user_id in number
    );

    procedure send_finance_ameritrade_req (
        p_acc_num      varchar2,
        p_claim_number number,
        p_claim_amount in number
    );

    procedure notify_nacha_result (
        p_account_type in varchar2,
        p_file_name    in varchar2
    );   -- Added by Swamy for Nacha Ticket#7723

 --  Ticket #7856 Added by rprabu for form_5500 invoice renewal report
    procedure daily_online_rwl_inv_form_5500;

--  Ticket #8683  Added by rprabu for  FSA rollover notification
    procedure notify_rollover (
        p_acc_id          in number,
        p_rollover_amount number,
        p_plan_type       in varchar2
    );

--- Ticket 9072 added by rprabu for     Sprint 27: EDI Error Report
    procedure notify_edi_discrepancy_report (
        p_entrp_id  in number,
        p_file_name varchar2
    );
-- Added by Jagadeesh
    procedure insert_notifications (
        p_from_address    in varchar2,
        p_to_address      in varchar2,
        p_cc_address      in varchar2,
        p_subject         in varchar2,
        p_message_body    in varchar2,
        p_user_id         in number,
        p_acc_id          in number default null,
        p_template_name   in varchar2,
        x_notification_id out number
    );

-- Added by Joshi 9141
-- Added by Joshi 9141
    procedure send_ga_er_notification (
        p_acc_id    in number,
        p_source    in varchar2    -- Added by Swamy for Ticket#11368(broker)
        ,
        x_notify_id out number
    );
--- Ticket 9537 added by Jaggi for     Sprint 31: EDI Contact
    procedure notify_edi_file_received (
        p_entrp_id  in number,
        p_file_name varchar2
    );
-- Added by Jaggi #9902
    procedure notify_broker_auth_required (
        p_broker_name varchar2,
        p_acc_id      in number,
        p_user_id     in number
    );
-- Added by Jaggi #9902
    procedure notify_broker_req_approved (
        p_acc_id  in number,
        p_user_id in number
    );
-- Added by Jaggi #10431
    procedure send_app_correction_mail (
        p_acc_id          in number,
        p_enrolled_by     in number,
        p_send_back_notes varchar2,
        p_action          varchar2,
        p_action_by       varchar2
    );

-- Added by Swamy for Ticket#10747
    procedure notify_broker_ren_decl_plan (
        p_acc_id       in varchar2,
        p_user_id      in varchar2,
        p_entrp_id     in varchar2,
        p_ben_pln_name in varchar2,
        p_ren_dec_flg  in varchar2,
        p_acc_num      in varchar2
    );

 -- Added by Swamy for Ticket#10747
    procedure notify_broker_hra_fsa_plan_renew (
        p_acc_id       in varchar2,
        p_plan_type    in varchar2,
        p_acc_num      in varchar2,
        p_ben_plan_id  in varchar2,
        p_product_type in varchar2,
        p_user_id      in varchar2,
        p_entrp_id     in varchar2
    );
-- Added by Jaggi #11119
    procedure daily_setup_renewal_invoice_notify (
        p_batch_number in number,
        p_source       in varchar2
    );
-- Added by Jaggi #11265
    procedure get_cobra_welcome_letters;
-- Added by Jaggi #11265
    procedure get_cobra_welcome_letter_body (
        p_acc_id              in number,
        p_plan_selection_type in varchar2
    );

 -- Added by Jaggi for Ticket#11368
    procedure notify_ga_hra_fsa_plan_renew (
        p_acc_id       in varchar2,
        p_plan_type    in varchar2,
        p_acc_num      in varchar2,
        p_ben_plan_id  in varchar2,
        p_product_type in varchar2,
        p_user_id      in varchar2,
        p_entrp_id     in varchar2
    );

-- Added by jaggi for Ticket#11368
    procedure notify_ga_ren_decl_plan (
        p_acc_id       in varchar2,
        p_user_id      in varchar2,
        p_entrp_id     in varchar2,
        p_ben_pln_name in varchar2,
        p_ren_dec_flg  in varchar2,
        p_acc_num      in varchar2
    );

    procedure hra_fsa_employer_balances_report;

    procedure hra_fsa_emp_bal_report_05312023;

    procedure hra_fsa_emp_bal_report_03312023;

    procedure employer_hra_fsa_bal_report;

-- Added by Joshi for 12139.
    procedure send_req_to_add_remitt_bank (
        p_acc_id          number,
        p_entity_type     varchar2,
        p_entity_id       in number,
        x_notification_id out number
    );

 -- Added by swamy on  01/07/2024 for 12247
    procedure bank_email_notifications (
        p_bank_acct_id    in number,
        p_bank_status     in varchar2,
        p_entity_type     in varchar2,
        p_entity_id       in number,
        p_denial_reason   in varchar2,
        p_user_id         in number,
        x_notification_id out number
    );

-- Added by Swamy for Ticket#12361 21/11/2024
-- Mail should trigger to primary,broker and compliance team when send mail is clicked from SAM service documents of the employer.
-- Only the latest ben plan rto docs is considered to send the mail.
    procedure rto_pop_email_notifications (
        p_entrp_id        in number,
        p_entity_name     in varchar2,
        p_attachment_id   in number,
        p_user_id         in number,
        x_notification_id out number
    );

--Added by Joshi for 12621
    procedure er_add_remitt_bank_notiification;

end pc_notifications;
/


-- sqlcl_snapshot {"hash":"7b3a3beeb51b3e7d3609f37b00fa9e27d53d8475","type":"PACKAGE_SPEC","name":"PC_NOTIFICATIONS","schemaName":"SAMQA","sxml":""}