create or replace package samqa.pc_notify_template is
    procedure insert_template (
        p_template_name     in varchar2,
        p_template_subject  in varchar2,
        p_template_body     in varchar2,
        p_event             in varchar2,
        p_notification_type in varchar2,
        p_status            in varchar2,
        p_to_address        in varchar2,
        p_cc_address        in varchar2,
        p_user_id           in number
    );

    function get_subject (
        p_template_name in varchar2
    ) return varchar2;

    function get_body (
        p_template_name in varchar2
    ) return varchar2;

    function get_template_name (
        p_event_name in varchar2
    ) return varchar2;

end pc_notify_template;
/


-- sqlcl_snapshot {"hash":"ac92e7df8c2a41263ac13075a72d1b178c3eba99","type":"PACKAGE_SPEC","name":"PC_NOTIFY_TEMPLATE","schemaName":"SAMQA","sxml":""}