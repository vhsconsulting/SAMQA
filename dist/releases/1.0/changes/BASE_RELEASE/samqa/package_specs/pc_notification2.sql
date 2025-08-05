-- liquibase formatted sql
-- changeset SAMQA:1754374138943 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_notification2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_notification2.sql:null:306e7c0870e6349489e6896da92ba1aec6325419:create

create or replace package samqa.pc_notification2 as
    type varchar2_tbl is
        table of varchar2(300) index by binary_integer;
  /* TODO enter package declarations (types, exceptions, methods etc) here */
    procedure process_events (
        p_event_name in varchar2 default null
    );

    procedure insert_sms_notifications (
        p_acc_id          in number default null,
        p_phone_number    in varchar2,
        p_sms_text        in varchar2,
        p_event_name      in varchar2    -- Added by Swamy on 11/Feb/2020 for Ticket#8722
        ,
        x_notification_id out number
    );

    procedure set_sms_token (
        p_token    in varchar2,
        p_string   in varchar2,
        p_notif_id in number
    );

    procedure insert_events (
        p_acc_id      in number,
        p_pers_id     in number,
        p_event_name  in varchar2,
        p_entity_type in varchar2,
        p_entity_id   in number,
        p_ssn         in varchar2 default null
    );

    procedure get_notification_template (
        p_event_name          in varchar2,
        p_sms_template_name   out varchar2,
        p_email_template_name out varchar2,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    );

-- Added by Swamy for Ticket#7920(Alert Notification) Sprint 21
    type alert_pref_rec is record (
            acc_id             number,
            lookup_code        varchar2(30),
            lookup_description varchar2(1000),
            subscribe_to_sms   varchar2(1),
            subscribe_to_email varchar2(1),
            category           varchar2(100),
            order_by_flg       varchar2(1)
    );
    type alert_pref_t is
        table of alert_pref_rec;
    function get_alert_preferences (
        p_ssn in varchar2
    ) return alert_pref_t
        pipelined
        deterministic;

    function get_email_preference (
        p_ssn        in varchar2,
        p_event_name varchar2
    ) return varchar2;

    procedure insert_alert_preferences (
        p_ssn                in varchar2,
        p_event_type         in varchar2_tbl,
        p_subscribe_to_sms   in varchar2_tbl,
        p_subscribe_to_email in varchar2_tbl,
        p_user_id            in number,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    );

-- End of Addition by Swamy for Ticket#7920(Alert Notification) Sprint 21
-- Added by Joshi for capturing the email and phone changes in the history table

    procedure insert_audit_security_info (
        p_pers_id            in number,
        p_user_id            in varchar2,
        p_email              in varchar2,
        p_phone_no           in varchar2,
        p_new_email_phone_no in varchar2   -- Added by Swamy for Ticket#9774
    );

    procedure er_qb_balances_report;

    procedure ee_qb_balances_report;

    procedure daily_feedback_report;

end pc_notification2;
/

