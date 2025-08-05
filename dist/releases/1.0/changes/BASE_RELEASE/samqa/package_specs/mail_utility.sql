-- liquibase formatted sql
-- changeset SAMQA:1754374133576 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\mail_utility.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/mail_utility.sql:null:104442b827470d6f3f44d6208e9aae6302f4e204:create

create or replace package samqa.mail_utility as
    procedure report_emails (
        p_from_email   in varchar2,
        p_to_email     in varchar2,
        p_file_name    in varchar2,
        p_sql          in varchar2,
        p_html_message in varchar2,
        p_report_title in varchar2
    );

    procedure send_file_in_emails (
        p_from_email   in varchar2,
        p_to_email     in varchar2,
        p_file_name    in varchar2,
        p_sql          in varchar2,
        p_html_message in varchar2,
        p_report_title in varchar2
    );

    procedure send_email (
        from_name varchar2,
        to_names  varchar2,
        subject   varchar2,
        mesg      varchar2
    );

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      varchar2 default '',
        html_message varchar2 default '',
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samfiles,
        clob_attach  samclobs default null,
        blob_attach  samblobs default null
    );

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      clob,
        html_message varchar2 default '',
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samfiles,
        clob_attach  samclobs default null,
        blob_attach  samblobs default null
    );

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      varchar2 default '',
        html_message clob,
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samfiles,
        clob_attach  samclobs default null,
        blob_attach  samblobs default null
    );

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      clob,
        html_message clob,
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samfiles,
        clob_attach  samclobs default null,
        blob_attach  samblobs default null
    );

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      varchar2 default '',
        html_message varchar2 default '',
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samclobs
    );

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      clob,
        html_message varchar2 default '',
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samclobs
    );

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      varchar2 default '',
        html_message clob,
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samclobs
    );

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      clob,
        html_message clob,
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samclobs
    );

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      varchar2 default '',
        html_message varchar2 default '',
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samblobs
    );

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      clob,
        html_message varchar2 default '',
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samblobs
    );

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      varchar2 default '',
        html_message clob,
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samblobs
    );

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      clob,
        html_message clob,
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        attach       samblobs
    );

    procedure email_files (
        from_name    varchar2,
        to_names     varchar2,
        subject      varchar2,
        message      varchar2 default '',
        html_message varchar2 default '',
        cc_names     varchar2 default null,
        bcc_names    varchar2 default null,
        filename1    varchar2 default null,
        filetype1    varchar2 default 'text/plain',
        filename2    varchar2 default null,
        filetype2    varchar2 default 'text/plain',
        filename3    varchar2 default null,
        filetype3    varchar2 default 'text/plain'
    );

    procedure html_email (
        p_to      in varchar2,
        p_from    in varchar2,
        p_subject in varchar2,
        p_text    in varchar2 default null,
        p_html    in varchar2 default null
    );

    procedure send_file (
        p_from_email    in varchar2,
        p_to_email      in varchar2,
        p_file_name     in varchar2,
        p_directory     in varchar2,
        p_dir_path      in varchar2,
        p_html_message  in varchar2,
        p_report_title  in varchar2,
        p_col_tbl       in gen_xl_xml.varchar2_tbl,
        p_col_value_tbl in gen_xl_xml.varchar2_tbl
    );

    procedure email_reports (
        p_file_name    in varchar2,
        p_report_title in varchar2,
        p_email        in varchar2,
        p_dir          in varchar2
    );

end mail_utility;
/

