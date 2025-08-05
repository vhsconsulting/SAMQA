create or replace package body samqa.pc_incident_notifications as
/*
   This package is used for opportunity TICKET SYSTEM
   All functions related to email notificaitons should be in this package
   Created by Yang, 20240119
*/
    g_smtp_host  varchar2(256) := '172.24.16.115';  --'216.109.157.30';
    g_smtp_port  number := 25;
    g_from_name  varchar2(50) := 'Sterling Ticketing System'; -- added by Yang, 20240118 
    g_from_email varchar2(100) := 'tickets-noreply@sterlingadministration.com';

    procedure send_email (
        p_notification_id in number
    ) is
   -- Change the boundary string, if needed, which demarcates boundaries of
   -- parts in a multi-part email, and should not appear inside the body of
   -- any part of the e-mail:
        boundary           varchar2(255) default 'CES.Boundary.DACA587499938898';
        recipients         varchar2(32767);
        directory_path     varchar2(256);
        file_path          varchar2(256);
        mime_type          varchar2(256);
        file_name          varchar2(256);
        cr                 varchar2(1) := chr(13);
        lf                 varchar2(1) := chr(10);
        crlf               varchar2(2) := cr || lf;
        p_mesg             varchar2(32767);
        p_from             varchar2(1000);
        conn               utl_smtp.connection;
        i                  binary_integer;
        my_code            number;
        my_errm            varchar2(32767);
        l_html_message     varchar2(32000);
        v_cc_list          varchar2(2000);   -- multiple cc list
        cc_parties         varchar2(2000);   -- multi cc list

        cursor c_notification is
        select
            from_address,
            to_address,
            cc_address,
            subject,
            message_body
        from
            incident_notifications
        where
                notification_id = p_notification_id
            and mail_status = 'READY';

        c_notification_rec c_notification%rowtype;
    begin
        conn := utl_smtp.open_connection(g_smtp_host, g_smtp_port);
        open c_notification;
        fetch c_notification into c_notification_rec;
        close c_notification;
        utl_smtp.helo(conn, g_smtp_host);
        utl_smtp.mail(conn, c_notification_rec.from_address);
       -- pc_log.log_error('p_notification_id:'||p_notification_id||' TO:',c_notification_rec.to_address||'CC:'||c_notification_rec.cc_address);
        --IF instr(c_notification_rec.cc_address, '@') > 0 THEN
        --   send_process_recipients(conn, c_notification_rec.to_address||';'||c_notification_rec.cc_address);    -- added by Yang, 20240117
       -- Else
        send_process_recipients(conn, c_notification_rec.to_address);    -- added by Yang, 20240117
        --send_process_recipients(conn, i.cc_address);    -- added by Yang, 20240117
       -- END IF;

        /*for j in (SELECT  REGEXP_SUBSTR(i.cc_address, '[^,]+', 1, LEVEL) AS cc_email_name
               FROM dual
               CONNECT BY REGEXP_SUBSTR(i.cc_address, '[^,]+', 1, LEVEL) IS NOT NULL) 
        loop
             CC_parties := CC_parties||';'|| j.cc_email_name;
             --utl_smtp.Rcpt(conn,j.cc_email_name);
        end loop;*/
        utl_smtp.open_data(conn);
        utl_smtp.write_data(conn, 'From: "'
                                  || g_from_name
                                  || '" <'
                                  || c_notification_rec.from_address
                                  || '>'
                                  || crlf
                                  || 'To:  '
                                  || c_notification_rec.to_address
                                  || crlf
                                  || 'Bcc:  '
                                  || c_notification_rec.cc_address
                                  || crlf
                                  || 'Subject :'
                                  || c_notification_rec.subject
                                  || crlf
                                  || 'Content-Type: text/html;'
                                  || crlf);
        --UTL_SMTP.write_data(conn, 'From: "'||g_from_name||'" <'||i.from_address||'>'||crlf|| 'To:  '||i.to_address||crlf||'Subject :'||i.subject||crlf||'Content-Type: text/html;'||crlf);
        utl_smtp.write_data(conn,
                            'Content-Type: text/html;'
                            || chr(13)
                            || chr(10)
                            || chr(13)
                            || chr(10));

        utl_smtp.write_data(conn, c_notification_rec.message_body);
        utl_smtp.close_data(conn);
        utl_smtp.quit(conn);
    exception
        when others then
            pc_log.log_error('EXCPTION: ', sqlerrm);
    end;

/* 
  Created: Yang 20240119
*/
    procedure send_process_recipients (
        p_mail_conn in out utl_smtp.connection,
        p_list      in varchar2
    ) as
        l_tab apex_application_global.vc_arr2;
    begin
        if trim(p_list) is not null then
--      pc_log.log_error('p_list: ',p_list);
            l_tab := apex_util.string_to_table(p_list, ';');
            for i in 1..l_tab.count loop
                if validate_email(trim(l_tab(i))) then
                    utl_smtp.rcpt(p_mail_conn,
                                  trim(l_tab(i)));
                end if;
            end loop;

        end if;
    exception
        when others then
            pc_log.log_error('EXCPTION: ', 'p_list:'
                                           || p_list
                                           || ':'
                                           || sqlerrm);
    end;

/* 
  Created: Yang 20240119
*/
    function feed_token (
        p_message_body in varchar2,
        p_token        in varchar2,
        p_string       in varchar2
    ) return varchar2 is
        v_message_body varchar2(4000);
    begin
        select
            replace(p_message_body, '<<'
                                    || p_token
                                    || '>>', p_string)
        into v_message_body
        from
            dual;

        return v_message_body;
    end feed_token;

/* 
  Created: Yang 20240119
  This function replaces the old function codes
  @TODO: Merge into SEND_INCIDENT_NOTE Yang
*/
    procedure send_incident (
        p_incident_id  in number,
        p_incident_url in varchar2,
        p_template     in varchar2
    ) is

        x_notify_id          number;
        l_template_body      varchar2(32000);
        l_name               varchar2(200);
        l_action             varchar2(500);
        l_dept_email         varchar2(1000);
        l_ticket_type        varchar2(20);
        l_ext_user           varchar2(100);
        x_error_status       varchar2(32000);
        l_ext_user_email     varchar2(500);
        cursor c_incident_details is
        select
            ticket_number,
            priority,
            account_name,
            subject,
            pc_incident_notifications.get_assign_name(assigned_pers) assigned_person,
            reporting_person
              --,Description
            ,
            '<div style="background-color:#e8f2b0;">'
            || description
            || '</div><hr>'                                          description,
            assigned_to,
            created_by,
            identifier,
            status,
            case
                when email_pref = 'D' then
                    email
                when email_pref = 'B' then
                    email
                    || ';'
                    || pc_incident_notifications.get_user_email_by_emp_id(assigned_pers)
                when email_pref = 'A' then
                    pc_incident_notifications.get_user_email_by_emp_id(assigned_pers)
            end                                                      email,
            watch_list,
            pc_incident_notifications.get_user_email(created_by)     reporting_person_email,
            ticket_type,
            decode(ticket_type,
                   'External',
                   pc_users.get_email_from_user_id(created_by),
                   null)                                             external_user_email
        from
            incident_details
        where
            incident_id = p_incident_id;

        incident_details_rec c_incident_details%rowtype;
        cursor c_template is
        select
            template_subject,
            template_body,
            cc_address,
            template_name
        from
            notification_template
        where
                notification_type = 'EXTERNAL'
            and template_name = p_template
            and status = 'A';

        template_rec         c_template%rowtype;
    begin
        pc_log.log_error('p_incident_id: ', p_incident_id);
        select
            case p_template
                when 'INCIDENT_EMAIL_NEW'          then
                    'New Ticket: '
                when 'INCIDENT_EMAIL_UPDATE'       then
                    'Updated Ticket: '
                when 'EXTERNAL_INCIDENT_EMAIL_NEW' then
                    'Sterling Support: Your Support Ticket <Ticket_Number> Has Been Created: '
                else
                    ''
            end
        into l_action
        from
            dual;

        open c_incident_details;
        loop
            fetch c_incident_details into incident_details_rec;
            exit when c_incident_details%notfound;
            l_name := get_acc_name(incident_details_rec.account_name);
            l_ticket_type := incident_details_rec.ticket_type;
            l_dept_email := 'Jagadeesh.Reddy@sterlingadministration.com;Sreekanth.Mareedu@sterlingadministration.com;syed.gouse@sterlingadministration.com'
            ;
            l_ext_user := get_user_name_details(lower(nvl(
                get_user_name(incident_details_rec.created_by),
                pc_users.get_user_name(incident_details_rec.created_by)
            )));

            l_ext_user_email := incident_details_rec.external_user_email;
            if user in ( 'SAMDEV', 'SAMQA', 'SAMDEMO' ) then
                select
                    decode(user, 'SAMDEV', 'DEV Testing', 'SAMQA', 'QA Testing',
                           'SAMDEMO', 'DEMO Testing')
                    || '-'
                    || l_action
                into l_action
                from
                    dual;

            end if;

            open c_template;
            fetch c_template into template_rec;
            close c_template;
            l_template_body := template_rec.template_body;
            l_template_body := feed_token(l_template_body, 'department', incident_details_rec.assigned_to);
            l_template_body := feed_token(l_template_body, 'incident_subject', incident_details_rec.subject);
            l_template_body := feed_token(l_template_body, 'priority', incident_details_rec.priority);
            l_template_body := feed_token(l_template_body, 'status', incident_details_rec.status);
            l_template_body := feed_token(l_template_body, 'Identifier', incident_details_rec.identifier);
            l_template_body := feed_token(l_template_body, 'incident_desc', incident_details_rec.description);
            l_template_body := feed_token(l_template_body,
                                          'incident_acc',
                                          nvl(l_name, 'No Account Name'));
            l_template_body := feed_token(l_template_body, 'incident_link', p_incident_url);
            l_template_body := feed_token(l_template_body,
                                          'created_by',
                                          nvl(incident_details_rec.reporting_person, l_ext_user));

            l_template_body := feed_token(l_template_body, 'assigned_to', incident_details_rec.assigned_person);
            l_template_body := feed_token(l_template_body, 'assigned_dept', incident_details_rec.assigned_to);
            l_template_body := feed_token(l_template_body, 'ticket_number', incident_details_rec.ticket_number);
            l_template_body := feed_token(l_template_body, 'ticket_description', incident_details_rec.description);
            pc_incident_notifications.insert_incident_notifications(
                p_from_address  => g_from_email,
                p_to_address    =>
                              case
                                  when p_template = 'EXTERNAL_INCIDENT_EMAIL_NEW' then
                                      l_ext_user_email --l_dept_email
                                  else
                                      l_dept_email
                                                          --incident_details_rec.Email||';'||incident_details_rec.watch_list||';'||incident_details_rec.Reporting_person_email
                              end,
                p_cc_address    => template_rec.cc_address,
                p_subject       =>
                           case
                               when p_template = 'EXTERNAL_INCIDENT_EMAIL_NEW' then
                                   'Sterling Support: Your Support Ticket'
                                   || '-'
                                   || incident_details_rec.ticket_number
                                   || ' '
                                   || 'Has Been Created'
                               else
                                   l_action
                                   || incident_details_rec.ticket_number
                                   || ' -- '
                                   || incident_details_rec.subject
                           end,
                p_message_body  => l_template_body,
                p_mail_status   => 'READY',
                p_template_name => template_rec.template_name,
                p_user_id       => incident_details_rec.created_by,
                p_incident_id   => p_incident_id,
                x_notify_id     => x_notify_id,
                x_error_status  => x_error_status
            );

              -- Send email
            send_email(p_notification_id => x_notify_id);

              -- Update status 
            update incident_notifications
            set
                mail_status = 'SENT'
            where
                notification_id = x_notify_id;

        end loop;

        close c_incident_details;
    exception
        when others then
            pc_log.log_error('EXCPTION: ', sqlerrm);
    end send_incident;

/* 
  Created: Yang 20231213
  Replace the old function codes
  TODO: merge into send_incident
*/
    procedure send_incident_note (
        p_incident_id  in number,
        p_incident_url in varchar2,
        p_template     in varchar2
    ) is

        x_notify_id           number;
        l_template_body       varchar2(32000);
        l_name                varchar2(200);
        l_action              varchar2(500);
        l_sum                 varchar2(4000);
        crlf                  varchar2(200 char) := utl_tcp.crlf;
        l_row                 number;
        l_notes_assigned_pers varchar2(32000);
        l_dept_email          varchar2(1000);
        l_ticket_type         varchar2(20);
        l_ext_user            varchar2(100);
        x_error_status        varchar2(2000);
        l_ext_user_email      varchar2(500);
        cursor c_incident_details is
        select
            id.ticket_number,
            id.priority,
            id.account_name,
            id.subject,
            id.description,
            id.assigned_to,
            id.created_by,
            id.identifier,
            id.status,
            '<div style="background-color:#e8f2b0;"><b>'
            ||
            case ih.text
                    when 'Commented' then
                        'New comment added'
                    when 'Modified'  then
                        'Ticket updated'
                    when 'Created'   then
                        'Ticket created'
                    else
                        ''
            end
            || '</b>&nbsp;&nbsp;&nbsp;<i>'
            || to_char(ih.created_date, 'YYYY-MM-DD HH24:MI:SS')
            || ' '
            || 'EDT'
            || ' - '
            || get_user_name_details(upper(nvl(
                get_user_name(ih.created_by),
                pc_users.get_user_name(ih.created_by)
            )))
            || '</i>'
            || crlf
            ||
            case
                when notes_assigned_pers is not null then
                        '<p>Notes Assigned To: '
                        || pc_incident_notifications.get_assign_name(notes_assigned_pers)
                        || '</p>'
            end
            || crlf
            || ih.notes
            || '</div><hr>'                                                         notes,
            history_id
--              ,id.email
            ,
            case
                when email_pref = 'D' then
                    email
                when email_pref = 'B' then
                    email
                    || ';'
                    || pc_incident_notifications.get_user_email_by_emp_id(assigned_pers)
                when email_pref = 'A' then
                    pc_incident_notifications.get_user_email_by_emp_id(assigned_pers)
            end                                                                     email,
            id.watch_list,
            pc_incident_notifications.get_user_email(id.created_by)                 reporting_person_email,
            pc_incident_notifications.get_user_email_by_emp_id(notes_assigned_pers) notes_assigned_pers,
            pc_incident_notifications.get_assign_name(assigned_pers)                assigned_person,
            reporting_person,
            ticket_type,
            decode(ticket_type,
                   'External',
                   pc_users.get_email_from_user_id(id.created_by),
                   null)                                                            external_user_email
        from
            incident_details id,
            incident_history ih
        where
                id.ticket_number = ih.ticket_number
            and id.incident_id = p_incident_id
        order by
            ih.created_date desc;

        incident_details_rec  c_incident_details%rowtype;
        cursor c_template is
        select
            template_subject,
            template_body,
            cc_address,
            template_name
        from
            notification_template
        where
                notification_type = 'EXTERNAL'
            and template_name = p_template
            and status = 'A';

        template_rec          c_template%rowtype;
    begin
   --pc_log.log_error('p_incident_id: ',p_incident_id);     

        select
            case p_template
                when 'INCIDENT_EMAIL_NOTES'  then
                    'Updated Ticket: '
                when 'INCIDENT_EMAIL_UPDATE' then
                    'Updated Ticket: '
                when 'INCIDENT_EMAIL_CLOSED' then
                    'Closed Ticket: '
                else
                    ''
            end
        into l_action
        from
            dual;

        if user in ( 'SAMDEV', 'SAMQA', 'SAMDEMO' ) then
            select
                decode(user, 'SAMDEV', 'DEV Testing', 'SAMQA', 'QA Testing',
                       'SAMDEMO', 'DEMO Testing')
                || '-'
                || l_action
            into l_action
            from
                dual;

        end if;

        l_row := 0;
        open c_incident_details;
        loop
            fetch c_incident_details into incident_details_rec;
            l_row := l_row + 1;
            if l_row = 1 then
                l_notes_assigned_pers := incident_details_rec.notes_assigned_pers;
            end if;
            exit when c_incident_details%notfound;
            l_sum := l_sum
                     || nvl(incident_details_rec.notes, '*');
      --pc_log.log_error('incident_details_rec.History_id:',incident_details_rec.History_id);
        end loop;

        close c_incident_details;
        l_name := get_acc_name(incident_details_rec.account_name);
        l_ticket_type := incident_details_rec.ticket_type;
        l_dept_email := 'Jagadeesh.Reddy@sterlingadministration.com;Sreekanth.Mareedu@sterlingadministration.com;syed.gouse@sterlingadministration.com,Sonam.Sherpa@sterlingadministration.com'
        ;
        l_ext_user := get_user_name_details(lower(nvl(
            get_user_name(incident_details_rec.created_by),
            pc_users.get_user_name(incident_details_rec.created_by)
        )));

        l_ext_user_email := incident_details_rec.external_user_email;
        open c_template;
        fetch c_template into template_rec;
        close c_template;
        l_template_body := template_rec.template_body;
        l_template_body := feed_token(l_template_body, 'department', incident_details_rec.assigned_to);
        l_template_body := feed_token(l_template_body, 'incident_subject', incident_details_rec.subject);
        l_template_body := feed_token(l_template_body, 'priority', incident_details_rec.priority);
        l_template_body := feed_token(l_template_body, 'status', incident_details_rec.status);
        l_template_body := feed_token(l_template_body, 'Identifier', incident_details_rec.identifier);
        l_template_body := feed_token(l_template_body, 'incident_desc', incident_details_rec.description);
        l_template_body := feed_token(l_template_body,
                                      'incident_acc',
                                      nvl(l_name, 'No Account Name'));
        l_template_body := feed_token(l_template_body, 'incident_link', p_incident_url);
        l_template_body := feed_token(l_template_body, 'incident_notes', l_sum);
        l_template_body := feed_token(l_template_body,
                                      'author',
                                      nvl(
                                       get_user_name(incident_details_rec.created_by),
                                       pc_users.get_user_name(incident_details_rec.created_by)
                                   ));

        l_template_body := feed_token(l_template_body,
                                      'created_by',
                                      nvl(incident_details_rec.reporting_person, l_ext_user));

        l_template_body := feed_token(l_template_body, 'assigned_to', incident_details_rec.assigned_person);
        l_template_body := feed_token(l_template_body, 'assigned_dept', incident_details_rec.assigned_to);
        l_template_body := feed_token(l_template_body, 'ticket_number', incident_details_rec.ticket_number);
        l_template_body := feed_token(l_template_body, 'subject', incident_details_rec.subject);
        pc_incident_notifications.insert_incident_notifications(
            p_from_address  => g_from_email,
            p_to_address    =>
                          case
                              when p_template = 'EXTERNAL_INCIDENT_UPDATE_EMAIL' then
                                  l_ext_user_email --l_dept_email
                              else
                                  l_dept_email
                                                          --incident_details_rec.Email||';'||incident_details_rec.watch_list||';'||incident_details_rec.Reporting_person_email
                          end,
            p_cc_address    => template_rec.cc_address,
            p_subject       =>
                       case
                           when p_template = 'EXTERNAL_INCIDENT_UPDATE_EMAIL' then
                               'Sterling Support: Ticket '
                               || '-'
                               || incident_details_rec.ticket_number
                               || ' '
                               || 'Has Been Updated'
                           else
                               l_action
                               || incident_details_rec.ticket_number
                               || ' -- '
                               || incident_details_rec.subject
                       end,
            p_message_body  => l_template_body,
            p_mail_status   => 'READY',
            p_template_name => template_rec.template_name,
            p_user_id       => incident_details_rec.created_by,
            p_incident_id   => p_incident_id,
            x_notify_id     => x_notify_id,
            x_error_status  => x_error_status
        );

              -- Send email
        send_email(p_notification_id => x_notify_id);

              -- Update status 
        update incident_notifications
        set
            mail_status = 'SENT'
        where
            notification_id = x_notify_id;

    exception
        when others then
            pc_log.log_error('EXCPTION: ', sqlerrm);
            null;
    end send_incident_note;

-- Added by Jaggi
    function get_acc_name (
        p_acc_num in varchar2
    ) return varchar2 is
        l_acc_name varchar2(3200);
    begin
        for j in (
            select
                b.name
            from
                account    a,
                enterprise b
            where
                    a.entrp_id = b.entrp_id
                and a.acc_num = p_acc_num
            union
            select
                b.first_name
                || ' '
                || b.last_name as name
            from
                account a,
                person  b
            where
                    a.pers_id = b.pers_id
                and a.acc_num = p_acc_num
        ) loop
            l_acc_name := j.name;
        end loop;

        return l_acc_name;
    exception
        when others then
            null;
    end get_acc_name;

    function get_user_name_details (
        p_user_name varchar2
    ) return varchar2 is
        l_user_name varchar2(50);
    begin
        select
            nvl(first_name
                || ' '
                || last_name, p_user_name)
        into l_user_name
        from
            employee  e,
            sam_users s
        where
                e.user_id = s.user_id
            and term_date is null
            and upper(user_name) = upper(p_user_name);

        return l_user_name;
    exception
        when no_data_found then
            return p_user_name;
        when others then
            return p_user_name;
    end;

-- Created: Yang 20240129    
    function validate_email (
        p_email varchar2
    ) return boolean is
        v_c number := 0;
    begin
        select
            count(1)
        into v_c
        from
            dual
        where
            regexp_like ( p_email,
                          '[a-zA-Z0-9._%-]+@[a-zA-Z0-9._%-]+\.[a-zA-Z]{2,4}' );

        if v_c > 0 then
            return true;
        else
            return false;
        end if;
    end validate_email;

-- Added by Jaggi 02/12/2024
    function get_assign_name (
        p_emp_id in number
    ) return varchar2 is
        l_assign_name varchar2(3200);
    begin
        for j in (
            select
                a.first_name
                || ' '
                || a.last_name name
            from
                employee a
            where
                emp_id = p_emp_id
        ) loop
            l_assign_name := j.name;
        end loop;

        return l_assign_name;
    exception
        when others then
            null;
    end get_assign_name;

-- Added by Jaggi
    function get_user_email (
        p_user_id number
    ) return varchar2 is
        l_email varchar2(3200);
    begin
        for j in (
            select
                *
            from
                employee
            where
                user_id = p_user_id
        ) loop
            l_email := j.email;
        end loop;

        return l_email;
    exception
        when others then
            null;
    end get_user_email;

 -- Added by Jaggi
    function get_user_email_by_emp_id (
        p_emp_id number
    ) return varchar2 is
        l_email varchar2(3200);
    begin
        for j in (
            select
                *
            from
                employee
            where
                emp_id = p_emp_id
        ) loop
            l_email := j.email;
        end loop;

        return l_email;
    exception
        when others then
            null;
    end get_user_email_by_emp_id;

 -- Added by Jaggi
    function get_dept_email_by_dept (
        p_dept varchar2
    ) return varchar2 is
        l_email varchar2(3200);
    begin
        for j in (
            select
                description
            from
                lookups
            where
                    lookup_name = 'DEPT_EMAIL'
                and lower(meaning) = lower(p_dept)
        ) loop
            l_email := j.description;
        end loop;

        return l_email;
    exception
        when others then
            null;
    end get_dept_email_by_dept;

   -- Added by Jaggi
    function get_external_tickets (
        p_entity_id   in number,
        p_entity_type varchar2
    ) return external_tickets_record_t
        pipelined
        deterministic
    is
        l_external_tickets_t external_tickets_row_t;
    begin
        for i in (
            select
                incident_id,
                ticket_number,
                subject,
                description,
                nvl(status, 'New')                                       as status,
                case
                    when upper(assigned_to) in ( 'EDI', 'IT', 'COBRA' ) then
                        upper(assigned_to)
                    else
                        initcap(assigned_to)
                end                                                      assigned_to,
                pc_incident_notifications.get_assign_name(assigned_pers) assigned_pers,
                ticket_type,
                to_char(creation_date, 'MM/DD/YYYY')                     creation_date,
                resolution
            from
                incident_details
            where
                    entity_id = p_entity_id
                and upper(entity_type) = p_entity_type
            order by
                incident_id desc
        ) loop
            l_external_tickets_t.incident_id := i.incident_id;
            l_external_tickets_t.ticket_number := i.ticket_number;
            l_external_tickets_t.subject := i.subject;
            l_external_tickets_t.description := i.description;
            l_external_tickets_t.status := i.status;
            l_external_tickets_t.assigned_to := i.assigned_to;
            l_external_tickets_t.assigned_pers := i.assigned_pers;
            l_external_tickets_t.ticket_type := i.ticket_type;
            l_external_tickets_t.creation_date := i.creation_date;
            l_external_tickets_t.resolution := i.resolution;
            pipe row ( l_external_tickets_t );
        end loop;
    end get_external_tickets;

    -- Added by Jaggi
    function get_broker_assoc_accounts (
        p_broker_id    in number,
        p_product_type varchar2
    ) return broker_assoc_accounts_record_t
        pipelined
        deterministic
    is
        l_broker_assoc_accounts_t broker_assoc_accounts_row_t;
    begin
        for x in (
            select
                ltrim(e.name) name,
                a.acc_num,
                a.account_type
            from
                account    a,
                enterprise e,
                broker     b
            where
                    a.entrp_id = e.entrp_id
                and b.broker_id = a.broker_id
                and account_status != 5
                and a.broker_id = p_broker_id
                and a.account_type = p_product_type
        ) loop
            l_broker_assoc_accounts_t.name := x.name;
            l_broker_assoc_accounts_t.acc_num := x.acc_num;
            l_broker_assoc_accounts_t.account_type := x.account_type;
            pipe row ( l_broker_assoc_accounts_t );
        end loop;
    end get_broker_assoc_accounts; 

-- Added by Jaggi
    function get_case_ident_by_prdt_id (
        p_case_identifier varchar2,
        p_product_type    varchar2
    ) return case_identifier_record_t
        pipelined
        deterministic
    is
        l_case_identifier_t case_identifier_row_t;
    begin
        for i in (
            select
                pc_lookups.get_meaning(a.lookup_code, a.lookup_name) identifier_type,
                lookup_code
            from
                lookups a
            where
                    lookup_name = p_case_identifier
                and p_product_type in ( 'FSA', 'HRA' )
                and lookup_code in ( '1B', '1C', '1D', '1E', '1F',
                                     '1G' )
            union
            select
                pc_lookups.get_meaning(a.lookup_code, a.lookup_name) identifier_type,
                lookup_code
            from
                lookups a
            where
                    lookup_name = p_case_identifier
                and p_product_type in ( 'HSA' )
                and lookup_code in ( '1A', '1B', '1C', '1D' )
            union
            select
                pc_lookups.get_meaning(a.lookup_code, a.lookup_name) identifier_type,
                lookup_code
            from
                lookups a
            where
                    lookup_name = p_case_identifier
                and p_product_type in ( 'ERISA_WRAP', 'Cafeteria' )
                and lookup_code in ( '1C', '1G' )
            union
            select
                pc_lookups.get_meaning(a.lookup_code, a.lookup_name) identifier_type,
                lookup_code
            from
                lookups a
            where
                    lookup_name = p_case_identifier
                and p_product_type in ( 'COBRA' )
                and lookup_code in ( '1B', '1C', '1D', '1H' )
            union
            select
                pc_lookups.get_meaning(a.lookup_code, a.lookup_name) identifier_type,
                lookup_code
            from
                lookups a
            where
                    lookup_name = p_case_identifier
                and p_product_type in ( 'POP' )
                and lookup_code in ( '1C', '1E', '1G' )
        ) loop
            l_case_identifier_t.case_identifier := i.identifier_type;
            l_case_identifier_t.product_type := p_product_type;
            l_case_identifier_t.lookup_code := i.lookup_code;
            pipe row ( l_case_identifier_t );
        end loop;
    end get_case_ident_by_prdt_id;

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
    ) is
        l_error_message varchar2(32000);
        l_url           varchar2(400);
    begin
        x_error_status := 'S';
        insert into incident_details (
            incident_id,
            ticket_number,
            status,
            priority,
            account_name,
            subject,
            description,
            assigned_to,
            reporting_person,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            external_identifier,
            ext_sub_identifier,
            ticket_type,
            external_display,
            email_pref,
            product_type,
            entity_id,
            entity_type
        ) values ( incident_details_seq.nextval,
                   concat('INC',
                          lpad(incident_details_seq.nextval, 5, '0')),
                   'New',
                   'Low',
                   nvl(p_acc_num, '-No Account Name-'),
                   p_subject,
                   p_description,
                   decode(p_case_identifier,
                          'Accountholder Assistance',
                          'Health Savings Account',
                          'EDI Technical Assistance',
                          decode(p_product_type, 'FSA', 'Customer service', 'HRA', 'Customer service',
                                 'HSA', 'EDI', 'COBRA', 'EDI'),
                          'Invoice/Banking Question',
                          case
                           when p_sub_case_identifier is not null then
                               decode(p_sub_case_identifier, 'Having trouble making payment', 'billing', 'Invoice amount is incorrect'
                               , 'billing',
                                      'Autopayment not working', 'billing', 'Invoice missing/not visible in portal', 'billing', 'Account Management'
                                      )
                           else 'finance'
                       end,
                          'Report Assistance',
                          decode(p_product_type, 'FSA', 'Customer service', 'HRA', 'Customer service',
                                 'HSA', 'Health Savings Account', 'COBRA', 'cobra'),
                          'Nondiscrimination Testing Assistance',
                          'compliance',
                          'Participant Assistance',
                          'Customer service',
                          'QB Assistance',
                          'cobra',
                          'Plan Document Assistance',
                          decode(p_product_type, 'FSA', 'Customer service', 'HRA', 'Customer service',
                                 'compliance')),
                   get_user_name_details(lower(nvl(
                       get_user_name(p_user_id),
                       pc_users.get_user_name(p_user_id)
                   ))),
                   p_user_id,
                   sysdate,
                   p_user_id,
                   sysdate,
                   p_case_identifier,
                   p_sub_case_identifier,
                   'External',
                   'N',
                   'B',
                   p_product_type,
                   p_entity_id,
                   p_entity_type ) returning incident_id,
                                             ticket_number into x_incident_id, x_ticket_number;
 
          --Update email
        update incident_details
        set
            email = pc_incident_notifications.get_dept_email_by_dept(assigned_to)
        where
            incident_id = x_incident_id;
 
         -- History
        insert into incident_history (
            history_id,
            incident_id,
            ticket_number,
            text,
            status,
            created_by,
            created_date,
            notes,
            display_comment_flag
        ) values ( incident_history_seq.nextval,
                   x_incident_id,
                   x_ticket_number,
                   'Created',
                   'New',
                   p_user_id,
                   sysdate,
                   '<p>Ticket '
                   || x_ticket_number
                   || ' was created</p>',
                   'Y' ) returning history_id into x_history_id;

      -- send Email Notify
        if user = 'SAMDEV' then
            l_url := 'http://172.24.16.115:8082/ords/sam19db/sterlinghsa_dev/r/sterling-ticket-system/create-edit-ticket?p6_incident_id='
                     || x_incident_id
                     || '&cs=1TRUXgGDLxU1unCdtSEpB_KvoYNAk_fXc4viIdrQMpuG2LklLVPQE_oK4zQ3IVkDA9BR4PMiXOIjoNPBTqDNmvQ';
        elsif user = 'SAMQA' then
            l_url := 'http://172.24.16.115:8082/ords/sam19qa/sterlinghsa_qa/r/sterling-ticket-system/create-edit-ticket?p6_incident_id='
                     || x_incident_id
                     || '=1TRUXgGDLxU1unCdtSEpB_KvoYNAk_fXc4viIdrQMpuG2LklLVPQE_oK4zQ3IVkDA9BR4PMiXOIjoNPBTqDNmvQ';
        elsif user = 'SAMDEMO' then
            l_url := 'http://172.24.16.115:8082/ords/sam19qa/sterlinghsa_demo/r/sterling-ticket-system/create-edit-ticket?p6_incident_id='
                     || x_incident_id
                     || '=1TRUXgGDLxU1unCdtSEpB_KvoYNAk_fXc4viIdrQMpuG2LklLVPQE_oK4zQ3IVkDA9BR4PMiXOIjoNPBTqDNmvQ';
        elsif user = 'SAM' then
            l_url := 'http://172.24.16.115:8082/ords/sam19qa/sterlinghsa/r/sterling-ticket-system/create-edit-ticket?p6_incident_id='
                     || x_incident_id
                     || '=1TRUXgGDLxU1unCdtSEpB_KvoYNAk_fXc4viIdrQMpuG2LklLVPQE_oK4zQ3IVkDA9BR4PMiXOIjoNPBTqDNmvQ';
        end if;

        -- Sam users  
        send_incident(x_incident_id, l_url, 'INCIDENT_EMAIL_NEW');
        -- Online user
        send_incident(x_incident_id, null, 'EXTERNAL_INCIDENT_EMAIL_NEW');
    exception
        when others then
            x_error_status := 'E';
            x_error_message := nvl(l_error_message,
                                   substr(sqlerrm, 1, 200));
            pc_log.log_error('Pc_Incident_Notifications.Insert_External_ticket',
                             'Error message '
                             || nvl(l_error_message,
                                    substr(sqlerrm, 1, 200)));

            raise;
--        ROLLBACK;
    end insert_external_ticket;

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
    ) is
        l_error_message varchar2(32000);
        l_url           varchar2(400);
    begin
        x_error_status := 'S';
         -- History
        insert into incident_history (
            history_id,
            incident_id,
            ticket_number,
            text,
            status,
            created_by,
            created_date,
            notes,
            display_comment_flag
        ) values ( incident_history_seq.nextval,
                   p_incident_id,
                   p_ticket_number,
                   'Commented',
                   'In_Progress',
                   p_user_id,
                   sysdate,
                   p_comment,
                   'Y' ) returning history_id into x_history_id;

        -- send Email Notify
        if user = 'SAMDEV' then
            l_url := 'http://172.24.16.115:8082/ords/sam19db/sterlinghsa_dev/r/sterling-ticket-system/create-edit-ticket?p6_incident_id='
                     || p_incident_id
                     || '&cs=1TRUXgGDLxU1unCdtSEpB_KvoYNAk_fXc4viIdrQMpuG2LklLVPQE_oK4zQ3IVkDA9BR4PMiXOIjoNPBTqDNmvQ';
        elsif user = 'SAMQA' then
            l_url := 'http://172.24.16.115:8082/ords/sam19qa/sterlinghsa_qa/r/sterling-ticket-system/create-edit-ticket?p6_incident_id='
                     || p_incident_id
                     || '=1TRUXgGDLxU1unCdtSEpB_KvoYNAk_fXc4viIdrQMpuG2LklLVPQE_oK4zQ3IVkDA9BR4PMiXOIjoNPBTqDNmvQ';
        elsif user = 'SAMDEMO' then
            l_url := 'http://172.24.16.115:8082/ords/sam19qa/sterlinghsa_demo/r/sterling-ticket-system/create-edit-ticket?p6_incident_id='
                     || p_incident_id
                     || '=1TRUXgGDLxU1unCdtSEpB_KvoYNAk_fXc4viIdrQMpuG2LklLVPQE_oK4zQ3IVkDA9BR4PMiXOIjoNPBTqDNmvQ';
        elsif user = 'SAM' then
            l_url := 'http://172.24.16.115:8082/ords/sam19qa/sterlinghsa/r/sterling-ticket-system/create-edit-ticket?p6_incident_id='
                     || p_incident_id
                     || '=1TRUXgGDLxU1unCdtSEpB_KvoYNAk_fXc4viIdrQMpuG2LklLVPQE_oK4zQ3IVkDA9BR4PMiXOIjoNPBTqDNmvQ';
        end if;

        send_incident(p_incident_id, l_url, 'INCIDENT_EMAIL_NEW');
    exception
        when others then
            x_error_status := 'E';
            x_error_message := nvl(l_error_message,
                                   substr(sqlerrm, 1, 200));
            pc_log.log_error('Pc_Incident_Notifications.Insert_External_ticket',
                             'Error message '
                             || nvl(l_error_message,
                                    substr(sqlerrm, 1, 200)));

            raise;
            rollback;
    end update_external_ticket;

    procedure upd_incident_desc (
        p_incident_id  in number,
        p_desc         in varchar2,
        x_error_status out varchar2
    ) is
        l_error_message varchar2(32000);
    begin
        x_error_status := 'S';
--  pc_log.log_error('Upd_Incident_desc','P_incident_Id '||P_incident_Id||' P_Desc := '||P_Desc);
        update incident_details
        set
            description = p_desc
        where
            incident_id = p_incident_id;

    exception
        when others then
            x_error_status := 'E';
            pc_log.log_error('Pc_Incident_Notifications.Upd_Incident_desc',
                             'Error message '
                             || nvl(l_error_message,
                                    substr(sqlerrm, 1, 200)));

            raise;
            rollback;
    end upd_incident_desc;

    function get_ext_incident_comments (
        p_incident_id in number
    ) return ext_comments_record_t
        pipelined
        deterministic
    is
        l_ext_comments_t ext_comments_row_t;
    begin
        for i in (
            select
                id.ticket_number,
                id.priority,
                initcap(id.assigned_to)                                  assigned_to,
                get_user_name_details(lower(nvl(
                    get_user_name(ih.created_by),
                    pc_users.get_user_name(ih.created_by)
                )))                                                      created_by,
                case
                    when get_user_name(ih.created_by) is not null then
                        'Internal'
                    when pc_users.get_user_name(ih.created_by) is not null then
                        'External'
                end                                                      user_flag,
                case
                    when get_user_name(ih.created_by) is not null then
                        pc_incident_notifications.get_user_dept(ih.created_by)
                    else
                        null
                end                                                      user_dept,
                to_char(ih.created_date, 'Mon/DD/YYYY')                  created_date,
                id.status,
                ih.notes,
                case
                    when notes_assigned_pers is not null then
                        '<p>Notes Assigned To: '
                        || pc_incident_notifications.get_assign_name(notes_assigned_pers)
                        || '</p>'
                end                                                      notes_assigned_pers,
                pc_incident_notifications.get_assign_name(assigned_pers) assigned_person
            from
                     incident_details id
                inner join incident_history ih on id.incident_id = ih.incident_id
            where
                    id.incident_id = p_incident_id
                and ticket_type = 'External'
                and display_comment_flag = 'Y'
            order by
                ih.created_date desc
        ) loop
            l_ext_comments_t.priority := i.priority;
            l_ext_comments_t.ticket_number := i.ticket_number;
            l_ext_comments_t.assigned_to := i.assigned_to;
            l_ext_comments_t.created_by := i.created_by;
            l_ext_comments_t.user_flag := i.user_flag;
            l_ext_comments_t.user_dept := i.user_dept;
            l_ext_comments_t.created_date := i.created_date;
            l_ext_comments_t.status := i.status;
            l_ext_comments_t.notes := i.notes;
            l_ext_comments_t.assigned_person := i.assigned_person;
            l_ext_comments_t.notes_assigned_pers := i.notes_assigned_pers;
            pipe row ( l_ext_comments_t );
        end loop;
    end get_ext_incident_comments;

    function get_ext_api_incident_comments (
        p_incident_id in number
    ) return ext_api_incident_comments
        pipelined
        deterministic
    is

        l_record               get_ext_api_incident_comments_request_t;
        l_ticket_number        varchar2(20);
        l_priority             varchar2(10);
        l_assigned_to          varchar2(100);
        l_created_by           varchar2(50);
        l_user_flag            varchar2(10);
        l_user_dept            varchar2(250);
        l_created_date         varchar2(50);
        l_status               varchar2(10);
        l_notes                varchar2(32000);
        l_notes_assigned_pers  varchar2(100);
        l_file_attachment      varchar2(500);
        l_attachment_id        number;
        l_attachment           blob;
        l_file_name            varchar2(250);
        l_assigned_person      varchar2(100);
        l_return_error_message varchar2(500);
        pragma autonomous_transaction;
    begin
        for cur_json in (
            select
                json_arrayagg(
                    json_object(
                        key 'TICKET_NUMBER' value ide.ticket_number,
                                key 'PRIORITY' value ide.priority,
                                key 'FILE_ATTACHMENT' value(
                            select
                                json_arrayagg(
                                    json_object( --attachments--
                                        key 'ASSIGNED_TO' value ide.assigned_to,
                                                key 'CREATED_BY' value get_user_name_details(lower(nvl(
                                            get_user_name(ih.created_by),
                                            pc_users.get_user_name(ih.created_by)
                                        ))),
                                                key 'USER_FLAG' value
                                            case
                                                when get_user_name(ih.created_by) is not null then
                                                    'Internal'
                                                when pc_users.get_user_name(ih.created_by) is not null then
                                                    'External'
                                            end,
                                                key 'USER_DEPT' value
                                            case
                                                when get_user_name(ih.created_by) is not null then
                                                    pc_incident_notifications.get_user_dept(ih.created_by)
                                                else
                                                    null
                                            end,
                                                key 'CREATED_DATE' value to_char(ih.created_date, 'YYYY-MM-DD HH:MI AM'),
                                                key 'STATUS' value ide.status,
                                                key 'NOTES_ASSIGNED_PERS' value
                                            case
                                                when notes_assigned_pers is not null then
                                                    '<p>Notes Assigned To: '
                                                    || pc_incident_notifications.get_assign_name(notes_assigned_pers)
                                                    || '</p>'
                                            end,
                                                key 'NOTES' value ih.notes,
                                                key 'FILES' value(
                                            select
                                                json_arrayagg(
                                                    json_object( --attachments--
                                                        key 'FILE_NAME' value abc.file_name,
                                                        key 'ATTACHMENT_ID' value abc.attachment_id
                                                    returning clob)
                                                returning clob)
                                            from
                                                incident_attachments abc
                                            where
                                                    incident_id = p_incident_id
                                                and history_id = ih.history_id
                                        )
                                    returning clob)
                                returning clob)
                            from
                                (
                                    select
                                        *
                                    from
                                        incident_history ih
                                    where
                                            ih.incident_id = p_incident_id
                                        and display_comment_flag = 'Y'
                                    order by
                                        ih.created_date
                                ) ih
                        )
                    returning clob)
                returning clob) comments
            from
                incident_details ide
            where
                    ide.incident_id = p_incident_id
                and ticket_type = 'External'
        ) loop
            begin
                l_record.col1 := cur_json.comments;
                l_ticket_number := null;
                l_ticket_number := json_value(l_record.col1, '$.TICKET_NUMBER');
                l_priority := json_value(l_record.col1, '$.PRIORITY');
                l_file_attachment := json_value(l_record.col1, '$.FILE_ATTACHMENT');
                l_file_name := json_value(l_record.col1, '$.FILE_ATTACHMENT.FILE_NAME');
                l_attachment_id := json_value(l_record.col1, '$.FILE_ATTACHMENT.ATTACHMENT_ID');
                l_assigned_to := json_value(l_record.col1, '$.FILE_ATTACHMENT.ASSIGNED_TO');
                l_created_by := json_value(l_record.col1, '$.FILE_ATTACHMENT.CREATED_BY');
                l_user_flag := json_value(l_record.col1, '$.FILE_ATTACHMENT.USER_FLAG');
                l_user_dept := json_value(l_record.col1, '$.FILE_ATTACHMENT.USER_DEPT');
                l_created_date := json_value(l_record.col1, '$.FILE_ATTACHMENT.CREATED_DATE');
                l_status := json_value(l_record.col1, '$.FILE_ATTACHMENT.STATUS');
                l_notes := json_value(l_record.col1, '$.FILE_ATTACHMENT.NOTES');
                l_notes_assigned_pers := json_value(l_record.col1, '$.FILE_ATTACHMENT.NOTES_ASSIGNED_PERS');
                pipe row ( l_record );
            exception
                when no_data_needed then
                    null;
                when others then
                    l_return_error_message := sqlerrm;
            end;
        end loop;
    end get_ext_api_incident_comments;

    function get_user_dept (
        p_user_id in number
    ) return varchar2 is
        v_user_dept varchar2(4000);
    begin
        select
            lookups.meaning
        into v_user_dept
        from
            employee   a,
            department b,
            lookups
        where
                a.dept_no = b.dept_no
            and upper(lookup_code) = upper(dept_code)
            and lookup_name = 'DEPT_EMAIL'
            and a.user_id = p_user_id;

        return v_user_dept;
    end get_user_dept;

    function get_product_types return product_types_record_t
        pipelined
        deterministic
    is
        l_product_types_t product_types_row_t;
    begin
        for i in (
            select
                pc_lookups.get_meaning(a.lookup_code, a.lookup_name) product_type
            from
                lookups a
            where
                    lookup_name = 'ACCOUNT_TYPE'
                and lookup_code in ( 'COBRA', 'ERISA_WRAP', 'FSA', 'HRA', 'HSA',
                                     'POP' )
            union
            select
                'Cafeteria'
            from
                dual
        ) loop
            l_product_types_t.product_type := i.product_type;
            pipe row ( l_product_types_t );
        end loop;
    end get_product_types;

 -- Added by Jaggi
    function get_sub_case_identifier (
        p_case_identifier varchar2
    ) return sub_case_identifier_record_t
        pipelined
        deterministic
    is
        l_sub_case_identifier_t sub_case_identifier_row_t;
    begin
        for i in (
            select
                pc_lookups.get_meaning(a.lookup_code, a.lookup_name) dept,
                description                                          identifier_type
            from
                lookups a
            where
                    lookup_name = 'SUB_CASE_IDENTIFIER'
                and upper(p_case_identifier) in ( 'INVOICE' )
                and lookup_code in ( '1A', '1B', '1C', '1D', '1E',
                                     '1F', '1G', '1H' )
        ) loop
            l_sub_case_identifier_t.indentifier_type := i.identifier_type;
            l_sub_case_identifier_t.dept := i.dept;
            pipe row ( l_sub_case_identifier_t );
        end loop;
    end get_sub_case_identifier;

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
    ) is
        l_error_message varchar2(3200);
    begin
        insert into incident_notifications (
            notification_id,
            from_address,
            to_address,
            cc_address,
            subject,
            message_body,
            mail_status,
            template_name,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            incident_id
        ) values ( incident_notification_seq.nextval,
                   g_from_email,
                   p_to_address,
                   p_cc_address,
                   p_subject,
                   p_message_body,
                   'READY',
                   p_template_name,
                   sysdate,
                   p_user_id,
                   sysdate,
                   p_user_id,
                   p_incident_id ) returning notification_id into x_notify_id;

    exception
        when others then
            x_error_status := 'E';
            pc_log.log_error('Pc_Incident_Notifications.insert_incident_notifications',
                             'Error message '
                             || nvl(l_error_message,
                                    substr(sqlerrm, 1, 200)));

            raise;
--        ROLLBACK;                      
    end insert_incident_notifications;

end pc_incident_notifications;
/


-- sqlcl_snapshot {"hash":"a14b21a4c011a026fb79ae41d9dde195d6bf74b8","type":"PACKAGE_BODY","name":"PC_INCIDENT_NOTIFICATIONS","schemaName":"SAMQA","sxml":""}