create or replace package samqa.pc_nightly_email as
    procedure pending_accounts;

    procedure account_under_review;

    procedure error_accounts;

    procedure fee_bucket_close_acc;

    procedure fee_problem;

    procedure email_sam_users;

    procedure suspacious_accounts;

    procedure not_closed_accounts;

    procedure closing_accounts;

    procedure debit_card_balance;

    procedure claim_fee_problem;

    procedure unpaid_sales_accounts;

    procedure notify_er_terminated_ee_in_ach;

    procedure email_void_invoices;

    procedure notify_pending_approvals;

    procedure notify_account_termination;

   -- Scheduled from CRON TAB
    procedure schedule_fsahra_notifications;

    procedure schedule_hsa_notifications;

    procedure schedule_comp_notifications;

    procedure schedule_cobra_notifications;

    procedure schedule_general_notifications;

    procedure schedule_ext_notifications;

    procedure schedule_invoice_notifications;

end pc_nightly_email;
/


-- sqlcl_snapshot {"hash":"87eb547c48f82ee4f4920ea0e5f5e536e24f71ee","type":"PACKAGE_SPEC","name":"PC_NIGHTLY_EMAIL","schemaName":"SAMQA","sxml":""}