-- liquibase formatted sql
-- changeset SAMQA:1754374142283 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\process_bill_format.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/process_bill_format.sql:null:bdc06e8765f6a7f9492b5f045a34c10f40a30412:create

create or replace package samqa.process_bill_format as
    procedure export_bill_format_file (
        pv_file_name    in varchar2,
        p_user_id       in number,
        x_batch_num     out number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure insert_bank_det (
        p_batch_num     in number,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure process_bill_format_execute (
        pv_file_name    in varchar2,
        p_user_id       in number,
        x_batch_num     out number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

end process_bill_format;
/

