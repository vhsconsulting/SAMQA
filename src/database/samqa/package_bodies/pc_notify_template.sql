create or replace package body samqa.pc_notify_template is

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
    ) is
    begin
        insert into notification_template (
            notif_template_id,
            template_name,
            template_subject,
            template_body,
            event,
            notification_type,
            status,
            to_address,
            cc_address,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        ) values ( notif_template_seq.nextval,
                   p_template_name,
                   p_template_subject,
                   p_template_body,
                   p_event,
                   p_notification_type,
                   p_status,
                   p_to_address,
                   p_cc_address,
                   sysdate,
                   p_user_id,
                   sysdate,
                   p_user_id );

    end insert_template;

    function get_subject (
        p_template_name in varchar2
    ) return varchar2 is
        l_subject varchar2(3200);
    begin
        for x in (
            select
                template_subject
            from
                notification_template
            where
                template_name = p_template_name
        ) loop
            l_subject := x.template_subject;
        end loop;

        return l_subject;
    end get_subject;

    function get_body (
        p_template_name in varchar2
    ) return varchar2 is
        l_body varchar2(32000);
    begin
        for x in (
            select
                template_body
            from
                notification_template
            where
                template_name = p_template_name
        ) loop
            l_body := x.template_body;
        end loop;

        return l_body;
    end get_body;

    function get_template_name (
        p_event_name in varchar2
    ) return varchar2 is
        l_template_name varchar2(32000);
    begin
        for x in (
            select
                template_name
            from
                notification_template
            where
                event = p_event_name
        ) loop
            l_template_name := x.template_name;
        end loop;

        return l_template_name;
    end get_template_name;

end pc_notify_template;
/


-- sqlcl_snapshot {"hash":"a6169d2f5050cbc1e8dab66c03be5c1fd5ef191a","type":"PACKAGE_BODY","name":"PC_NOTIFY_TEMPLATE","schemaName":"SAMQA","sxml":""}