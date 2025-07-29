create or replace package samqa.pc_incident_notifications as 
/*
   This package is used for INCIDENT TICKET SYSTEM
   All functions related to email notificaitons should be in this package
   Created by Yang, 20240119
*/
    procedure send_email (
        p_notification_id in number
    );

    procedure send_process_recipients (
        p_mail_conn in out utl_smtp.connection,
        p_list      in varchar2
    );

    procedure send_incident (
        p_incident_id  in number,
        p_incident_url in varchar2,
        p_template     in varchar2
    );

    procedure send_incident_note (
        p_incident_id  in number,
        p_incident_url in varchar2,
        p_template     in varchar2
    );

    function feed_token (
        p_message_body in varchar2,
        p_token        in varchar2,
        p_string       in varchar2
    ) return varchar2;

-- Added By Jaggi
    function get_acc_name (
        p_acc_num in varchar2
    ) return varchar2;

    function get_user_name_details (
        p_user_name varchar2
    ) return varchar2;

    function get_user_email (
        p_user_id number
    ) return varchar2;

    function get_user_email_by_emp_id (
        p_emp_id number
    ) return varchar2;

    function get_dept_email_by_dept (
        p_dept varchar2
    ) return varchar2;

-- Created: Yang 20240129    
    function validate_email (
        p_email varchar2
    ) return boolean;

-- Added By Jaggi 02/12/2024
    function get_assign_name (
        p_emp_id in number
    ) return varchar2;

-- Added By Jaggi 08/06/2024
    type external_tickets_row_t is record (
            incident_id   number,
            ticket_number varchar2(15),
            subject       varchar2(400),
            description   varchar2(4000),
            status        varchar2(20),
            assigned_to   varchar2(50),
            assigned_pers varchar2(50),
            ticket_type   varchar2(20),
            resolution    varchar2(4000),
            creation_date varchar2(20)
    );
    type external_tickets_record_t is
        table of external_tickets_row_t;
    function get_external_tickets (
        p_entity_id   in number,
        p_entity_type varchar2
    ) return external_tickets_record_t
        pipelined
        deterministic; 

-- Added By Jaggi 08/06/2024
    type broker_assoc_accounts_row_t is record (
            name         varchar2(200),
            acc_num      varchar2(20),
            account_type varchar2(20)
    );
    type broker_assoc_accounts_record_t is
        table of broker_assoc_accounts_row_t;
    function get_broker_assoc_accounts (
        p_broker_id    in number,
        p_product_type varchar2
    ) return broker_assoc_accounts_record_t
        pipelined
        deterministic;

    type case_identifier_row_t is record (
            lookup_code     varchar2(2),
            product_type    varchar2(20),
            case_identifier varchar2(200)
    );
    type case_identifier_record_t is
        table of case_identifier_row_t;
    function get_case_ident_by_prdt_id (
        p_case_identifier varchar2,
        p_product_type    varchar2
    ) return case_identifier_record_t
        pipelined
        deterministic;

    procedure insert_external_ticket (
        p_entity_id           in number,
        p_entity_type         in varchar2,
        p_product_type        in varchar2,
        p_case_identifier     in varchar2,
        p_acc_num             in varchar2,
        p_subject             in varchar2,
        p_description         in varchar2,
        p_sub_case_identifier in varchar2 default null,
        p_user_id             in number,
        x_incident_id         out number,
        x_history_id          out number,
        x_ticket_number       out varchar2,
        x_error_status        out varchar2,
        x_error_message       out varchar2
    );

    procedure update_external_ticket (
        p_incident_id   in number,
        p_ticket_number in varchar2,
        p_entity_id     in number,
        p_entity_type   in varchar2,
        p_comment       in varchar2,
        p_user_id       in number,
        x_history_id    out number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    );

    procedure upd_incident_desc (
        p_incident_id  in number,
        p_desc         in varchar2,
        x_error_status out varchar2
    );

    type ext_comments_row_t is record (
            priority            varchar2(20),
            ticket_number       varchar2(20),
            assigned_to         varchar2(200),
            created_by          varchar2(20),
            created_date        varchar2(50),
            status              varchar2(20),
            notes               varchar2(32000),
            notes_assigned_pers varchar2(500),
            assigned_person     varchar2(50),
            user_flag           varchar2(10),
            user_dept           varchar2(50)
    );
    type ext_comments_record_t is
        table of ext_comments_row_t;
    function get_ext_incident_comments (
        p_incident_id in number
    ) return ext_comments_record_t
        pipelined
        deterministic;

    type get_ext_api_incident_comments_request_t is record (
        col1 clob
    );
    type ext_api_incident_comments is
        table of get_ext_api_incident_comments_request_t;
    function get_ext_api_incident_comments (
        p_incident_id in number
    ) return ext_api_incident_comments
        pipelined
        deterministic;

    function get_user_dept (
        p_user_id in number
    ) return varchar2;

    type product_types_row_t is record (
        product_type varchar2(50)
    );
    type product_types_record_t is
        table of product_types_row_t;
    function get_product_types return product_types_record_t
        pipelined
        deterministic;

    type sub_case_identifier_row_t is record (
            indentifier_type varchar2(50),
            dept             varchar2(50)
    );
    type sub_case_identifier_record_t is
        table of sub_case_identifier_row_t;
    function get_sub_case_identifier (
        p_case_identifier varchar2
    ) return sub_case_identifier_record_t
        pipelined
        deterministic;

    procedure insert_incident_notifications (
        p_from_address  in varchar2,
        p_to_address    in varchar2,
        p_cc_address    in varchar2,
        p_subject       in varchar2,
        p_message_body  in varchar2,
        p_mail_status   in varchar2,
        p_template_name in varchar2,
        p_user_id       in varchar2,
        p_incident_id   in varchar2,
        x_notify_id     out number,
        x_error_status  out varchar2
    );

end pc_incident_notifications;
/


-- sqlcl_snapshot {"hash":"dfe5a32ba9d1a109f468214664e02cab139c04bd","type":"PACKAGE_SPEC","name":"PC_INCIDENT_NOTIFICATIONS","schemaName":"SAMQA","sxml":""}