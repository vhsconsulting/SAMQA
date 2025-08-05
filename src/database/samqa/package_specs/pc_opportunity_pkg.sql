create or replace package samqa.pc_opportunity_pkg as
    procedure send_email (
        p_notification_id in number
    );

    procedure send_process_recipients (
        p_mail_conn in out utl_smtp.connection,
        p_list      in varchar2
    );

    function feed_token (
        p_message_body in varchar2,
        p_token        in varchar2,
        p_string       in varchar2
    ) return varchar2;    

-- Added by Jaggi
    function feed_token_clob (
        p_clob  in clob,
        p_token in varchar2,
        p_value in varchar2
    ) return clob;

    function validate_email (
        p_email varchar2
    ) return boolean;

    procedure send_opportunity (
        p_acc_id   in number,
        p_opp_id   in number,
        p_opp_url  in varchar2,
        p_template in varchar2
    );

    procedure send_opportunity_note (
        p_user_id  in number,
        p_acc_id   in number,
        p_opp_id   in number,
        p_opp_url  in varchar2,
        p_template in varchar2
    );

    function get_acc_name (
        p_acc_id in number
    ) return varchar2;

    function get_emp_name (
        p_user_id in number
    ) return varchar2;

    function get_lookup_desc (
        p_meaning in varchar2
    ) return varchar2;

end pc_opportunity_pkg;
/


-- sqlcl_snapshot {"hash":"2450fe04982ec7a6f8e80d0e8aba8b2b8e2e04b3","type":"PACKAGE_SPEC","name":"PC_OPPORTUNITY_PKG","schemaName":"SAMQA","sxml":""}