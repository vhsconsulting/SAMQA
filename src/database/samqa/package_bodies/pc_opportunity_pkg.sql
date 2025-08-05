create or replace package body samqa.pc_opportunity_pkg as
/*
   This package is used for opportunity TICKET SYSTEM
   All functions related to email notificaitons should be in this package 
*/
    g_smtp_host  varchar2(256) := '172.24.16.114';  --'216.109.157.30';
    g_smtp_port  number := 25;
    g_from_name  varchar2(50) := 'Opportunity';
    g_from_email varchar2(100) := 'opportunity-noreply@sterlingadministration.com';

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
            opportunity_notifications
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
        send_process_recipients(conn, c_notification_rec.to_address);
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

    procedure send_process_recipients (
        p_mail_conn in out utl_smtp.connection,
        p_list      in varchar2
    ) as
        l_tab apex_application_global.vc_arr2;
    begin
        if trim(p_list) is not null then
            pc_log.log_error('p_list: ', p_list);
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

-- Added by Jaggi
    function feed_token_clob (
        p_clob  in clob,
        p_token in varchar2,
        p_value in varchar2
    ) return clob is
        l_clob clob;
    begin
        l_clob := replace(p_clob, '{'
                                  || p_token
                                  || '}', p_value);
        return l_clob;
    end;

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

    procedure send_opportunity (
        p_acc_id   in number,
        p_opp_id   in number,
        p_opp_url  in varchar2,
        p_template in varchar2
    ) is

        l_notify_id             number;
        l_template_body         varchar2(32000);
        l_name                  varchar2(200);
        l_acc_num               varchar2(200);
        l_acc_type              varchar2(200);
        l_subject               varchar2(200);
        l_action                varchar2(20);
        l_imp_stage             varchar2(200);
        l_primary_email         varchar2(4000);
        l_cc_address            varchar2(4000);
        l_email                 varchar2(4000);
        l_employer_name         varchar2(200);
        l_expected_close_date   varchar2(20);
        cursor c_opportunity_details is
        select
            acc_id,
            description,
            implementation_stage_cde,
            assigned_dept,
            email_pref,
            created_by,
            last_updated_by,
            assigned_emp_id,
            case
                when email_pref = 'D' then
                    pc_opportunity_pkg.get_lookup_desc(assigned_dept)
                when email_pref = 'B' then
                    pc_opportunity_pkg.get_lookup_desc(assigned_dept)
                    || ';'
                    || pc_incident_notifications.get_user_email_by_emp_id(assigned_emp_id)
                when email_pref = 'A' then
                    pc_incident_notifications.get_user_email_by_emp_id(assigned_emp_id)
            end email,
            expec_closed_date,
            case
                when pc_lookups.get_meaning(implementation_stage_cde, 'IMPLEMENTATION_STAGES') = 'Pending QA' then
                    pc_incident_notifications.get_user_email_by_emp_id(crm_id)
                else
                    null
            end crm_email
        from
            opportunity
        where
                acc_id = p_acc_id
            and opp_id = p_opp_id;

        opportunity_details_rec c_opportunity_details%rowtype;
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

        template_rec            c_template%rowtype;
    begin
        select
            case p_template
                when 'OPPORTUNITY_EMAIL_NEW'   then
                    'New opportunity: '
                when 'OPPORTUNITY_EMAIL_NOTES' then
                    'Updated opportunity: '
                else
                    ''
            end case
        into l_action
        from
            dual;

        open c_opportunity_details;
        loop
            fetch c_opportunity_details into opportunity_details_rec;
            l_name := get_acc_name(opportunity_details_rec.acc_id);
            l_acc_num := pc_account.get_acc_num_from_acc_id(opportunity_details_rec.acc_id);
            l_acc_type := pc_account.get_account_type(opportunity_details_rec.acc_id);
            l_imp_stage := pc_lookups.get_meaning(opportunity_details_rec.implementation_stage_cde, 'IMPLEMENTATION_STAGES');
            l_employer_name := pc_account.get_employer_name(p_acc_id);
            l_expected_close_date := to_char(opportunity_details_rec.expec_closed_date, 'MM/DD/YYYY');
            exit when c_opportunity_details%notfound;
            open c_template;
            fetch c_template into template_rec;
            close c_template;
            pc_log.log_error('send_opportunity p_acc_id: ', p_acc_id);
            pc_log.log_error('send_opportunity p_opp_id: ', p_opp_id);
            pc_log.log_error('send_opportunity opportunity_details_rec.Email: ', opportunity_details_rec.email);
            l_template_body := template_rec.template_body;
            l_template_body := feed_token(l_template_body, 'acc_num', l_acc_num);
            l_template_body := feed_token(l_template_body, 'acc_type', l_acc_type);
            l_template_body := feed_token(l_template_body, 'acc_name', l_name);
            l_template_body := feed_token(l_template_body, 'imp_stage', l_imp_stage);
            l_template_body := feed_token(l_template_body, 'Expected_Close_Date', l_expected_close_date);
            l_template_body := feed_token(l_template_body, 'Employer_Name', l_employer_name);
            l_template_body := feed_token(l_template_body, 'Opportunity_ID', p_opp_id);
            l_template_body := feed_token(l_template_body, 'Opportunity_link', p_opp_url); 

--       IF opportunity_details_rec.Email IS NOT NULL THEN
            insert into opportunity_notifications (
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
                acc_id,
                opp_id
            ) values ( opportunity_notification_seq.nextval,
                       g_from_email,
                       opportunity_details_rec.email
                       || ';'
                       || opportunity_details_rec.crm_email,
                       template_rec.cc_address,
                       'Opportunity created for '
                       || l_acc_num
                       || ' - '
                       || l_name,
                       l_template_body,
                       'READY',
                       template_rec.template_name,
                       sysdate,
                       opportunity_details_rec.created_by,
                       sysdate,
                       opportunity_details_rec.created_by,
                       p_acc_id,
                       p_opp_id ) returning notification_id into l_notify_id;         

          -- Send email
            send_email(p_notification_id => l_notify_id);

          -- Update status 
            update opportunity_notifications
            set
                mail_status = 'SENT'
            where
                notification_id = l_notify_id;              
--        END IF;

        end loop;

        close c_opportunity_details;
    exception
        when others then
            pc_log.log_error('PC_OPPORTUNITY_PKG send_opportunity EXCPTION: ', sqlerrm);
    end send_opportunity;

    procedure send_opportunity_note (
        p_user_id  in number,
        p_acc_id   in number,
        p_opp_id   in number,
        p_opp_url  in varchar2,
        p_template in varchar2
    ) is

        l_notify_id             number;
--  l_template_body       VARCHAR2(32767);
        l_template_body         clob;
        l_name                  varchar2(200);
        l_acc_num               varchar2(200);
        l_acc_status            varchar2(200);
        l_acc_type              varchar2(200);
        l_subject               varchar2(200);
        l_imp_stage             varchar2(200);
        l_assigned_dept         varchar2(200);
        l_assigned_pers         varchar2(200);
        l_status                varchar2(200);
        l_action                varchar2(200);
--  l_sum                 VARCHAR2(32767);
        l_sum                   clob;
        crlf                    varchar2(200 char) := utl_tcp.crlf;
        l_row                   number;
        l_primary_email         varchar2(4000);
        l_cc_address            varchar2(4000);
        l_email                 varchar2(4000);
        l_expected_close_date   varchar2(20);
        l_employer_name         varchar2(200);
        cursor c_opportunity_details is
        select
            acc_id,
            notes,
            implementation_stage_cde,
            assigned_dept,
            assigned_emp_id,
            email_pref,
            created_date,
            created_by,
            email,
            notes_assigned_pers,
            notes_assigned_dept,
            crm_email,
            expec_closed_date
        from
            (
                select
                    a.acc_id,
                    '<div style="background-color:#e8f2b0;"><b>'
                    ||
                    case b.text_type
                            when 'Commented'     then
                                'Notes added :- '
                            when 'Modified'      then
                                'Modified :-'
                            when 'File attached' then
                                'File attached :-'
                            else
                                ''
                    end
                    || '</b>;;;<i>'
                    || to_char(b.created_date, 'YYYY-MM-DD HH24:MI:SS')
                    || ' '
                    || 'EDT'
                    || ' - '
                    || get_user_name_details(upper(nvl(
                        get_user_name(b.created_by),
                        pc_users.get_user_name(b.created_by)
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
                    || b.text
                    || '</div><hr>'                                                         notes,
                    a.implementation_stage_cde,
                    assigned_dept,
                    pc_incident_notifications.get_assign_name(a.assigned_emp_id)            assigned_emp_id,
                    email_pref,
                    b.created_date,
                    get_user_name(b.created_by)                                             created_by,
                    case
                        when email_pref = 'D' then
                            pc_opportunity_pkg.get_lookup_desc(a.assigned_dept)
                        when email_pref = 'B' then
                            pc_opportunity_pkg.get_lookup_desc(a.assigned_dept)
                            || ';'
                            || pc_incident_notifications.get_user_email_by_emp_id(assigned_emp_id)
                        when email_pref = 'A' then
                            pc_incident_notifications.get_user_email_by_emp_id(assigned_emp_id)
                    end                                                                     email,
                    pc_incident_notifications.get_user_email_by_emp_id(notes_assigned_pers) notes_assigned_pers,
                    pc_opportunity_pkg.get_lookup_desc(b.notes_assigned_dept)               notes_assigned_dept,
                    b.history_id,
                    expec_closed_date,
                    case
                        when pc_lookups.get_meaning(implementation_stage_cde, 'IMPLEMENTATION_STAGES') = 'Pending QA' then
                            pc_incident_notifications.get_user_email_by_emp_id(a.crm_id)
                        else
                            null
                    end                                                                     crm_email
                from
                    opportunity         a,
                    opportunity_history b
                where
                        a.opp_id = b.opp_id
                    and a.acc_id = p_acc_id
                    and a.opp_id = p_opp_id
                    and b.text_type = 'Commented'
                    and p_template = 'OPPORTUNITY_EMAIL_NOTES'
                union all
                select
                    a.acc_id,
                    '<div style="background-color:#e8f2b0;"><b>'
                    ||
                    case b.text_type
                            when 'Commented'     then
                                'Notes added :- '
                            when 'Modified'      then
                                'Modified :-'
                            when 'File attached' then
                                'File attached :-'
                            else
                                ''
                    end
                    || '</b>;;;<i>'
                    || to_char(b.created_date, 'YYYY-MM-DD HH24:MI:SS')
                    || ' '
                    || 'EDT'
                    || ' - '
                    || get_user_name_details(upper(nvl(
                        get_user_name(b.created_by),
                        pc_users.get_user_name(b.created_by)
                    )))
                    || '</i>'
                    || crlf
                    || b.text
                    || '</div><hr>'                                                         notes,
                    a.implementation_stage_cde,
                    assigned_dept,
                    pc_incident_notifications.get_assign_name(a.assigned_emp_id)            assigned_emp_id,
                    email_pref,
                    b.created_date,
                    get_user_name(b.created_by)                                             created_by,
                    case
                        when email_pref = 'D' then
                            pc_opportunity_pkg.get_lookup_desc(assigned_dept)
                        when email_pref = 'B' then
                            pc_opportunity_pkg.get_lookup_desc(assigned_dept)
                            || ';'
                            || pc_incident_notifications.get_user_email_by_emp_id(assigned_emp_id)
                        when email_pref = 'A' then
                            pc_incident_notifications.get_user_email_by_emp_id(assigned_emp_id)
                    end                                                                     email,
                    pc_incident_notifications.get_user_email_by_emp_id(notes_assigned_pers) notes_assigned_pers,
                    pc_opportunity_pkg.get_lookup_desc(b.notes_assigned_dept)               notes_assigned_dept,
                    b.history_id,
                    expec_closed_date,
                    case
                        when pc_lookups.get_meaning(implementation_stage_cde, 'IMPLEMENTATION_STAGES') = 'Pending QA' then
                            pc_incident_notifications.get_user_email_by_emp_id(a.crm_id)
                        else
                            null
                    end                                                                     crm_email
                from
                    opportunity         a,
                    opportunity_history b
                where
                        a.opp_id = b.opp_id
                    and a.acc_id = p_acc_id
                    and a.opp_id = p_opp_id
                    and b.text_type != 'Commented'
                    and p_template = 'OPPORTUNITY_EMAIL_UPDATE'
            ) a
        order by
            a.history_id desc;

        opportunity_details_rec c_opportunity_details%rowtype;
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

        template_rec            c_template%rowtype;
    begin
        dbms_lob.createtemporary(l_sum, true);
        dbms_lob.createtemporary(l_template_body, true);
        l_row := 0;
        l_acc_status := pc_account.get_status(p_acc_id);
        l_name := get_acc_name(p_acc_id);
        l_acc_num := pc_account.get_acc_num_from_acc_id(p_acc_id);
        l_acc_type := pc_account.get_account_type(p_acc_id);
        l_employer_name := pc_account.get_employer_name(p_acc_id);
        l_expected_close_date := to_char(opportunity_details_rec.expec_closed_date, 'MM/DD/YYYY');
        open c_opportunity_details;
        loop
            fetch c_opportunity_details into opportunity_details_rec;
            exit when c_opportunity_details%notfound;
            l_row := l_row + 1;
            if l_row = 1 then
                if opportunity_details_rec.notes_assigned_pers is not null
                   or opportunity_details_rec.notes_assigned_dept is not null then
                    l_email := opportunity_details_rec.notes_assigned_pers
                               || ';'
                               || opportunity_details_rec.notes_assigned_dept;
                else
                    l_email := opportunity_details_rec.email
                               || ';'
                               || opportunity_details_rec.crm_email;
                end if;
            end if;

            exit when c_opportunity_details%notfound;      
--             l_sum        :=  l_sum || nvl(opportunity_details_rec.Notes,'*');
            dbms_lob.append(l_sum,
                            nvl(opportunity_details_rec.notes, '*'));
            l_imp_stage := pc_lookups.get_meaning(opportunity_details_rec.implementation_stage_cde, 'IMPLEMENTATION_STAGES');
        end loop;

        close c_opportunity_details;
        open c_template;
        fetch c_template into template_rec;
        close c_template;
        dbms_lob.writeappend(l_template_body,
                             length(template_rec.template_body),
                             template_rec.template_body);
        l_template_body := feed_token_clob(l_template_body, 'acc_num', l_acc_num);
        l_template_body := feed_token_clob(l_template_body, 'Employer_Name', l_employer_name);
        l_template_body := feed_token_clob(l_template_body, 'acc_type', l_acc_type);
        l_template_body := feed_token_clob(l_template_body, 'acc_status', l_acc_status);
        l_template_body := feed_token_clob(l_template_body, 'imp_stage', l_imp_stage);
        l_template_body := feed_token_clob(l_template_body, 'assigned_dept', opportunity_details_rec.assigned_dept);
        l_template_body := feed_token_clob(l_template_body, 'assigned_pers', opportunity_details_rec.assigned_emp_id);
        l_template_body := feed_token_clob(l_template_body,
                                           'updated_by',
                                           pc_opportunity_pkg.get_emp_name(p_user_id));
        l_template_body := feed_token_clob(l_template_body, 'Opportunity_ID', p_opp_id);
        l_template_body := feed_token_clob(l_template_body, 'Expected_Close_Date', l_expected_close_date);
        l_template_body := feed_token_clob(l_template_body, 'notes', l_sum);
        l_template_body := feed_token_clob(l_template_body, 'Opportunity_link', p_opp_url);
        if l_email is not null then
            insert into opportunity_notifications (
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
                acc_id,
                opp_id
            ) values ( opportunity_notification_seq.nextval,
                       g_from_email,
                       l_email,
                       template_rec.cc_address,
                       case
                           when p_template = 'OPPORTUNITY_EMAIL_NOTES' then
                               'Notes have been added to the opportunity for '
                               || l_acc_num
                               || ' - '
                               || l_name
                           else
                               'Update on Opportunity for '
                               || l_acc_num
                               || ' - '
                               || l_name
                       end,
                       l_template_body,
                       'READY',
                       p_template,
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_user_id,
                       p_acc_id,
                       p_opp_id ) returning notification_id into l_notify_id;          

--            pc_log.log_error('send_opportunity_note l_notify_id: ',l_notify_id);      

            -- Send email
            send_email(p_notification_id => l_notify_id);

            -- Update status 
            update opportunity_notifications
            set
                mail_status = 'SENT'
            where
                notification_id = l_notify_id;

        end if;

    exception
        when others then
            pc_log.log_error('PC_OPPORTUNITY_PKG send_opportunity_note EXCPTION: ', sqlerrm);
            null;
    end send_opportunity_note;

    function get_acc_name (
        p_acc_id in number
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
                and a.acc_id = p_acc_id
        ) loop
            l_acc_name := j.name;
        end loop;

        return l_acc_name;
    exception
        when others then
            null;
    end get_acc_name;

    function get_emp_name (
        p_user_id in number
    ) return varchar2 is
        l_emp_name varchar2(3200);
    begin
        for j in (
            select
                first_name
                || ' '
                || last_name name
            from
                employee
            where
                user_id = p_user_id
        ) loop
            l_emp_name := j.name;
        end loop;

        return l_emp_name;
    exception
        when others then
            null;
    end get_emp_name;

    function get_lookup_desc (
        p_meaning in varchar2
    ) return varchar2 is
        l_desc varchar2(3200);
    begin
        for j in (
            select
                description
            from
                lookups
            where
                    lookup_name = 'DEPT_EMAIL'
                and lower(meaning) = lower(p_meaning)
        ) loop
            l_desc := j.description;
        end loop;

        return l_desc;
    exception
        when others then
            pc_log.log_error('PC_OPPORTUNITY_PKG Get_Lookup_desc EXCPTION: ', sqlerrm);
            null;
    end get_lookup_desc;

end pc_opportunity_pkg;
/


-- sqlcl_snapshot {"hash":"ea980ecd94a5910c539889a23fed097b12df0ca5","type":"PACKAGE_BODY","name":"PC_OPPORTUNITY_PKG","schemaName":"SAMQA","sxml":""}