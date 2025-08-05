create or replace package samqa.pc_claim_automation as
    type number_tbl is
        table of number;
    type varchar2_tbl is
        table of varchar2(255);
    procedure batch_release_claim (
        p_entrp_id in number
    );

    procedure auto_release_claim (
        p_entrp_id     in number,
        p_batch_number in number
    );

    procedure write_claim_error_file (
        p_acc_num  in varchar2,
        p_claim_id in number,
        p_message  in varchar2
    );

    procedure write_claim_report_file;

    procedure new_auto_release_claim (
        p_entrp_id     in number,
        p_batch_number in number
    );

 /*  PROCEDURE write_unreleased_claim_file (p_entrp_id IN NUMBER, p_claim_amount IN NUMBER
   , p_er_balance IN NUMBER,p_product_type IN VARCHAR2,p_batch_number IN NUMBER);*/

    procedure write_unreleased_claim_file (
        p_batch_number in number
    );

    procedure write_released_claim_file (
        p_claim_id_tbl in number_tbl,
        p_batch_number in number
    );

    procedure write_claim_log_file (
        p_message in varchar2
    );

    procedure email_files (
        p_file_name    in varchar2,
        p_report_title in varchar2
    );

    procedure write_no_claim_inv_setup_file (
        p_batch_number in number
    );

    procedure write_bank_exception_file (
        p_batch_number in number
    );

    procedure write_invoiced_claim_file (
        p_invoice_id in number
    );

    procedure email_invoiced_claim_file;

    procedure write_released_claim_details (
        p_batch_number in number
    );

    procedure insert_process (
        p_claim_id       in number,
        p_process_status in varchar2,
        p_entrp_id       in number,
        p_product_type   in varchar2,
        p_pay_amount     in number,
        p_er_balance     in number,
        p_claim_status   in varchar2,
        p_batch_number   in number
    );

end pc_claim_automation;
/


-- sqlcl_snapshot {"hash":"b520081e7ded1a7b2592e0ee69adae72360d31c6","type":"PACKAGE_SPEC","name":"PC_CLAIM_AUTOMATION","schemaName":"SAMQA","sxml":""}