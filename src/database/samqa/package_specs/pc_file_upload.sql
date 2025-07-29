create or replace package samqa.pc_file_upload as
    procedure export_deposit_report (
        pv_file_name in varchar2,
        p_user_id    in number
    );

    procedure export_online_disbursement (
        pv_file_name in varchar2,
        p_user_id    in number
    );

    procedure insert_sql_file (
        p_file_name   in varchar2,
        p_sql         in varchar2,
        p_upload_file in varchar2,
        p_subject     in varchar2
    );

    function insert_file_seq (
        p_action in varchar2
    ) return number;

    function get_file_name (
        p_action in varchar2,
        p_result in varchar2 default 'RESULT'
    ) return varchar2;

    function get_file_seq (
        p_action in varchar2
    ) return varchar2;

    procedure export_attachments (
        p_file_name   in varchar2,
        p_user_id     in number,
        p_entity_name in varchar2,
        p_entity_id   in varchar2,
        p_doc_purpose in varchar2 default null,
        p_description in varchar2 default null
    );

    procedure export_online_attachments (
        p_file_name   in varchar2,
        p_mime_type   in varchar2,
        p_document    in blob,
        p_user_id     in number,
        p_entity_name in varchar2,
        p_entity_id   in varchar2
    );

    function get_creation_date (
        p_entity_id   in number,
        p_entity_name in varchar2
    ) return date;

    procedure export_ach_format_file (
        pv_file_name    in varchar2,
        p_user_id       in number,
        x_batch_num     out number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure insert_ach_bank_det (
        p_batch_num     in number,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure process_ach_format_execute (
        pv_file_name    in varchar2,
        p_user_id       in number,
        x_batch_num     out number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure export_list_bill (
        pv_file_name    in varchar2,
        p_user_id       in number,
        p_list_bill     in number,
        x_batch_num     out number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure insert_bill_details (
        p_batch_num     in number,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure process_bill_execute (
        pv_file_name    in varchar2,
        p_user_id       in number,
        p_list_bill     in number,
        x_batch_num     out number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure process_website_upload (
        p_batch_num     in number,
        p_user_id       in number,
        pv_file_name    in varchar2,
        p_entrp_id      in varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure export_sam_attachments (
        p_file_name   in varchar2,
        p_user_id     in number,
        p_entity_name in varchar2,
        p_entity_id   in varchar2,
        p_doc_purpose in varchar2 default null,
        p_description in varchar2 default null
    );

        ---------   16/07/2022 file Upload issue in COBRA Apex file upload, 
    procedure export_sam_cobra_attachments (
        p_file_name   in varchar2,
        p_user_id     in number,
        p_entity_name in varchar2,
        p_entity_id   in varchar2,
        p_doc_purpose in varchar2 default null,
        p_description in varchar2 default null
    );

    procedure export_pdf_application (
        p_file_name in varchar2
    );

    procedure load_document (
        p_dir in varchar2
    );

    procedure export_csv_file (
        p_file_name   in varchar2,
        p_acc_num     in varchar2,
        p_doc_purpose in varchar2 default 'ELECTRONIC_FEED'
    );

/*Ticket#5469.For COBRa Reconstrction */
    procedure export_attachments_new (
        p_file_name   in varchar2,
        p_user_id     in number,
        p_entity_name in varchar2,
        p_entity_id   in varchar2,
        p_doc_purpose in varchar2 default null,
        p_description in varchar2 default null
    );

    procedure export_document (
        p_file_name   in varchar2,
        p_entity_id   in varchar2,
        p_entity_name in varchar2,
        p_dir         in varchar2,
        p_doc_purpose in varchar2,
        p_note        in varchar2
    );

-- Added by Joshi for 9072
    procedure insert_file_upload_history (
        p_batch_num         in number,
        p_user_id           in number,
        pv_file_name        in varchar2,
        p_entrp_id          in varchar2,
        p_action            in varchar2,
        p_account_type      in varchar2,
        p_enrollment_source in varchar2,
        p_file_type         in varchar2,
        p_error             in varchar2 default null -- Added bu Joshi for 9670.
        ,
        x_file_upload_id    out number
    );

-- Added by Swamy for Ticket#12309
    procedure giact_insert_file_attachments (
        p_user_bank_stg_id in number,
        p_attachment_id    in number,
        p_entity_id        in number,
        p_entity_name      in varchar2,
        p_document_purpose in varchar2,
        p_batch_number     in number,
        p_source           in varchar2,
        x_error_status     out varchar2,
        x_error_message    out varchar2
    );

end pc_file_upload;
/


-- sqlcl_snapshot {"hash":"f7402ded07f7a3105cbe7fdccef543d4ac1cc7bd","type":"PACKAGE_SPEC","name":"PC_FILE_UPLOAD","schemaName":"SAMQA","sxml":""}