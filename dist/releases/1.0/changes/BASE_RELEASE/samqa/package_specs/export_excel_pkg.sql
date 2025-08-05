-- liquibase formatted sql
-- changeset SAMQA:1754374133418 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\export_excel_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/export_excel_pkg.sql:null:27163f2bc5adb9d617aa11f716395400d4e01d4e:create

create or replace package samqa.export_excel_pkg as
    procedure get_usable_sql (
        p_sql_in  in varchar2,
        p_sql_out out varchar2
    );

    procedure print_header (
        no_of_cols in number
    );

    procedure print_footer (
        no_of_cols in number
    );

    procedure print_report_header (
        p_region  in varchar2,
        p_page_id in number,
        p_app_id  in number,
        p_error   out varchar2
    );

    procedure print_report_values (
        p_page_id    in number,
        p_app_id     in number,
        p_app_user   in varchar2,
        p_session_id in varchar2,
        p_error      out varchar2
    );

    procedure print_report (
        p_region    in varchar2,
        p_file_name in varchar2 default 'excel_report',
        p_page_id   in number default v('APP_PAGE_ID')
    );

end export_excel_pkg;
/

