-- liquibase formatted sql
-- changeset SAMQA:1754374137678 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_file.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_file.sql:null:52836c9f33e87de55a3a30dc2ff49bc7590511a1:create

create or replace package samqa.pc_file is

-- ????? ??? ????????-???????? ?????? ????? WEB
-- 19.05.2004/SeF - ????????
-- ?????? ?? ???????? ?????
    procedure upload_request (
        table_name_in in varchar2,
        table_id_in   in varchar2,
        p_key         in varchar2
    );
-- ???????? ?????
    procedure upload (
        file           in varchar2,
        table_name_in  in varchar2,
        table_id_in    in varchar2,
        description_in in varchar2,
        p_key          in varchar2
    );
-- ???????? ?? ??????? ??????????? ??? ????????? ??????? ? ??????????????
-- (1-????,0-???)
    function is_there_are_attach (
        table_name_in in varchar2,
        table_id_in   in varchar2
    ) return number;
-- ???????? ????????
    procedure download (
        file_id_in in number,
        p_key      in varchar2
    );
-- ???????? ????????
    procedure download (
        name_in in varchar2
    );

    procedure download_attachment (
        attachment_id_in in number
    );

    procedure download_claim_doc (
        claim_id_in in number
    );

    procedure get_query_result_as_csv_file (
        in_query    in varchar2,
        in_filename in varchar2
    );

    procedure get_scheduler_details (
        p_scheduler_id in number,
        p_plan_type    in varchar2,
        p_entrp_id     in number
    );

    procedure get_hsa_scheduler_details (
        p_scheduler_id in number,
        p_entrp_id     in number
    );

    procedure import_crm_employer;

    procedure extract_error_from_log (
        p_in_file_name in varchar2,
        p_dir          in varchar2,
        x_file_name    out varchar2
    );

    function remove_line_feed (
        p_in_file_name in varchar2,
        p_dir          in varchar2,
        p_date         in varchar2
    ) return varchar2;

    procedure import_crm_employer_acc (
        p_acc_num in varchar2
    );

end pc_file;
/

