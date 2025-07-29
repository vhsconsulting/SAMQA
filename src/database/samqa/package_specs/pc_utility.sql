create or replace package samqa.pc_utility as

  -- Added by Joshi for Sam upgrade.

    type l_cursor is ref cursor;
    type ticker_rec is record (
            lvl                   number,
            label_name            varchar2(100),
            target_page_link      varchar2(1000),
            is_current_list_entry varchar2(2),
            icon                  varchar2(50)
    );
    type ticker_tbl is
        table of ticker_rec;
    type notes_rec is record (
            note_id      number,
            entity_type  varchar2(255),
            description  varchar2(4000),
            entered_date date,
            created_by   number,
            entity_id    varchar2(255)
    );
    type notes_tbl is
        table of notes_rec;
    type case_rec is record (
            case_number   number,
            case_name     varchar2(4000),
            description   varchar2(4000),
            date_entered  date,
            date_modified date,
            status        varchar2(25),
            resolution    varchar2(4000),
            assigned_user varchar2(200)
    );
    type case_tbl is
        table of case_rec;
    function get_ticket_info (
        p_entity_type varchar2,
        p_acct_type   varchar2,
        p_where_val1  number
    ) return ticker_tbl
        pipelined
        deterministic;

    function get_notes (
        p_page_no number
    ) return notes_tbl
        pipelined
        deterministic;

    function get_crm_cases (
        p_acc_num varchar2
    ) return case_tbl
        pipelined
        deterministic;

-- coded ends hete for sam upgrade

    procedure save_1099;

    procedure generate_1099 (
        p_year in varchar2
    );

    procedure generate_5498 (
        p_year in varchar2
    );

    procedure export_1099 (
        p_year in varchar2
    );
/* TODO enter package declarations (types, exceptions, methods etc) here */
    procedure download_file (
        p_file_name in varchar2,
        p_directory in varchar2
    );

    procedure purge_tables;

    procedure insert_notes (
        p_entity_id     in varchar2,
        p_entity_type   in varchar2,
        p_description   in varchar2,
        p_user_id       in varchar2,
        p_creation_date in date default sysdate,
        p_pers_id       in number default null,
        p_acc_id        in number default null,
        p_entrp_id      in number default null,
        p_action        in varchar2 default null
    );

    procedure break_notes (
        p_note_id in number
    );

    procedure assign_pers_entrp_id (
        p_entity_id   in varchar2,
        p_entity_type in varchar2
    );

    procedure export_cms_query_file;

    procedure export_cms_tin_file;

    procedure export_cms_msp_file;

    procedure import_cms_file (
        pv_file_name in varchar2,
        p_user_id    in number
    );

    procedure update_medicare_information;

    procedure update_plan_dates_cms;

    procedure update_tin_result;

    procedure update_msp_result;

    procedure generate_file (
        p_file_name    in varchar2,
        p_sql          in varchar2,
        p_report_title in varchar2
    );


 --   Added by rprabu on 31/08/2018 for the Ticket #6326 ( Sprint Cycle 8: DEMO- Can we have piyush run this nightly script)
    procedure delete_demo_renewals;

end pc_utility;
/


-- sqlcl_snapshot {"hash":"397abca0544e33e8af831647afa70c1a97cc5c62","type":"PACKAGE_SPEC","name":"PC_UTILITY","schemaName":"SAMQA","sxml":""}