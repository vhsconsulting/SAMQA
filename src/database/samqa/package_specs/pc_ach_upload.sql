create or replace package samqa.pc_ach_upload as
    procedure process_ach_upload (
        p_batch_num     in number,
        p_user_id       in number,
        p_source        in varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure derive_values_for_ach_upload (
        p_batch_num in number,
        p_user_id   in number,
        p_source    in varchar2
    );

    procedure validate_ach_upload (
        p_batch_num in number,
        p_user_id   in number,
        p_source    in varchar2
    );

    procedure insert_ach_upload (
        p_batch_num     in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure export_ach_upload_file (
        pv_file_name    in varchar2,
        p_user_id       in number,
        p_source        in varchar2 default 'SAM',
        x_batch_num     out number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure process_ftp_listbill (
        p_file_name     in varchar2,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

end pc_ach_upload;
/


-- sqlcl_snapshot {"hash":"233fe4c873a926c57918234ad1f4caf5c34a2128","type":"PACKAGE_SPEC","name":"PC_ACH_UPLOAD","schemaName":"SAMQA","sxml":""}