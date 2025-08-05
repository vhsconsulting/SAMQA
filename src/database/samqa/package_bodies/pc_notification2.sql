create or replace package body samqa.pc_notification2 as

    procedure process_events (
        p_event_name in varchar2 default null
    ) as
        l_person_name  varchar2(250);
        l_notif_id     number;
        l_service_type varchar2(250);  -- Added by Swamy for Prod Issue Ticket#11191
    begin

    -- process emails.
        for x in (
            select
                a.template_subject,
                a.template_body,
                a.cc_address,
                case
                    when e.event_name = 'EMAIL'
                         and e.entity_type = 'PERSON'
                         and e.email = o.email then
                        null
                    else
                        nvl(e.email, o.email)
                end                                    email,
                e.entity_id,
                e.acc_num,
                e.event_id,
                d.first_name
                || ' '
                || d.last_name                         pers_name,
                e.event_name,
                e.acc_id,
                e.pers_id,
                e.entity_type,
                to_char(e.creation_date, 'MM/DD/YYYY') process_date
            from
                notification_template a,
                event_notifications   e,
                person                d,
                online_users          o
            where
                    a.template_name = e.template_name
                and ( ( p_event_name is null
                        and e.event_name in (
                    select
                        lookup_code
                    from
                        lookups
                    where
                        lookup_name = 'ALERT_NOTIFICATION'
                ) )
                      or ( p_event_name is not null
                           and e.event_name = p_event_name ) )
                and a.status = 'A'
                and nvl(e.processed_flag, 'N') = 'N'
                and d.pers_id = e.pers_id
                and replace(d.ssn, '-') = o.tax_id
                and o.user_type = 'S'
                and o.user_status = 'A'
                and o.confirmed_flag = 'Y'
                and o.find_key is not null
                and e.event_type = 'EMAIL'
        ) loop
            pc_log.log_error('PROCESS_EVENT Event Name', x.event_name);
            pc_log.log_error('PROCESS_EVENT Email ', x.email);
            if x.email is not null then
                pc_notifications.insert_notifications(
                    p_from_address    => 'customer.service@sterlingadministration.com',
                    p_to_address      => x.email,
                    p_cc_address      => x.cc_address,
                    p_subject         => x.template_subject,
                    p_message_body    => x.template_body,
                    p_acc_id          => x.acc_id,
                    p_user_id         => 0,
                    x_notification_id => l_notif_id
                );

                pc_notifications.set_token('ACCOUNT_NAME', x.pers_name, l_notif_id);
                if ( x.event_name = 'CLAIM_PROCESSED'
                or x.event_name = 'CLAIM_DENIED' ) then
                    for y in (
                        select
                            nvl(service_type, 'HSA') service_type,
                            nvl(c.denied_amount, 0)  denied_amount,
                            nvl(c.claim_pending, 0)  claim_pending,
                            nvl(c.claim_paid, 0)     claim_paid,
                            c.pers_id
                        from
                            claimn c
                        where
                                claim_id = x.entity_id
                            and x.entity_type = 'CLAIMN'
                    ) loop
                        pc_notifications.set_token('CLAIM_ID', x.entity_id, l_notif_id);
                        pc_notifications.set_token_subject('CLAIM_ID', x.entity_id, l_notif_id);
                             -- Added by Swamy for Prod Issue Ticket#11191
                        l_service_type := y.service_type;
                        if l_service_type = 'HSA' then
                            for k in (
                                select
                                    account_type
                                from
                                    account
                                where
                                    pers_id = y.pers_id
                            ) loop
                                l_service_type := k.account_type;
                            end loop;
                        end if;

                            ---PC_NOTIFICATIONS.SET_TOKEN ('PLAN_TYPE',Y.service_type,l_notif_id);
                        pc_notifications.set_token('PLAN_TYPE', l_service_type, l_notif_id);   -- Added by Swamy for Prod Issue Ticket#11191

                        if x.event_name = 'CLAIM_PROCESSED' then
                            pc_notifications.set_token('CLAIM_AMOUNT',
                                                       format_money(y.claim_paid),
                                                       l_notif_id);
                        else
                            pc_notifications.set_token('CLAIM_AMOUNT',
                                                       format_money(y.denied_amount),
                                                       l_notif_id);
                        end if;

                        pc_notifications.set_token('PROCESS_DATE', x.process_date, l_notif_id);
                    end loop;
                end if;

                update email_notifications
                set
                    mail_status = 'READY',
                    event = x.event_name
                where
                    notification_id = l_notif_id;

            end if;

            if x.event_name = 'EMAIL' then
                pc_log.log_error('PROCESS_EVENT old email id loop  ', x.email);
                for xx in (
                    select
                        email
                    from
                        online_user_security_history oh1
                    where
                            oh1.pers_id = x.pers_id
                        and user_id <> - 1
                        and oh1.change_id = (
                            select
                                max(change_id)
                            from
                                online_user_security_history oh2
                            where
                                    oh2.pers_id = oh1.pers_id
                                and oh2.email is not null
                        )
                ) loop
                    pc_log.log_error('PROCESS_EVENT old email id loop  ', xx.email);
                    pc_notifications.insert_notifications(
                        p_from_address    => 'customer.service@sterlingadministration.com',
                        p_to_address      => xx.email,
                        p_cc_address      => x.cc_address,
                        p_subject         => x.template_subject,
                        p_message_body    => x.template_body,
                        p_acc_id          => x.acc_id,
                        p_user_id         => 0,
                        x_notification_id => l_notif_id
                    );

                    pc_notifications.set_token('ACCOUNT_NAME', x.pers_name, l_notif_id);
                    update email_notifications
                    set
                        mail_status = 'READY',
                        event = x.event_name
                    where
                        notification_id = l_notif_id;

                end loop;

            end if;

            update event_notifications
            set
                processed_flag = 'Y',
                email = x.email
            where
                event_id = x.event_id;

        end loop;

    -- process sms.
        for x in (
            select
                a.template_subject,
                a.template_body,
                a.cc_address,
                e.email                                email
                    --,NVL(e.phone_number, strip_bad(ui.verified_phone_number)) phone_number
                ,
                strip_bad(ui.verified_phone_number)    phone_number    -- Commented above and Added verified_phone_number by Swamy for Ticket#9910 on 25/05/2021
                ,
                ui.verified_phone_type,
                e.acc_num,
                e.event_id,
                d.first_name
                || ' '
                || d.last_name                         pers_name,
                e.event_name,
                e.acc_id,
                e.entity_id,
                e.entity_type,
                to_char(e.creation_date, 'MM/DD/YYYY') process_date,
                d.pers_id
            from
                notification_template a,
                event_notifications   e,
                person                d,
                user_security_info    ui,
                online_users          o
            where
                    a.template_name = e.template_name
                --AND  E.EVENT_NAME IN ( SELECT LOOKUP_CODE FROM LOOKUPS WHERE LOOKUP_NAME ='ALERT_NOTIFICATION')
                and ( ( p_event_name is null
                        and e.event_name in (
                    select
                        lookup_code
                    from
                        lookups
                    where
                        lookup_name = 'ALERT_NOTIFICATION'
                ) )
                      or ( p_event_name is not null
                           and e.event_name = p_event_name ) )
                and a.status = 'A'
                and nvl(e.processed_flag, 'N') = 'N'
                and d.pers_id = e.pers_id
                and replace(d.ssn, '-') = o.tax_id
                and o.user_id = ui.user_id
                and e.event_type = 'SMS'
        ) loop
            pc_log.log_error('PROCESS_EVENT Event Name', x.event_name);
            pc_log.log_error('PROCESS_EVENT Email ', x.email
                                                     || ' x.verified_phone_type :='
                                                     || x.verified_phone_type);

            if upper(x.verified_phone_type) = 'MOBILE' then
                pc_notification2.insert_sms_notifications(
                    p_acc_id          => x.acc_id,
                    p_phone_number    => x.phone_number,
                    p_sms_text        => x.template_body,
                    p_event_name      => x.event_name   -- Added by Swamy on 11/Feb/2020 for Ticket#8722
                    ,
                    x_notification_id => l_notif_id
                );

            -- PC_NOTIFICATIONS.SET_TOKEN ('ACCOUNT_NAME',x.pers_name,l_notif_id);
                pc_log.log_error('processing insert,l_notif_id ', l_notif_id);

          --IF ( x.event_name ='CLAIM_PROCESSED' OR x.event_name ='CLAIM_DENIED') THEN
                if x.event_name in ( 'CLAIM_PROCESSED', 'CLAIM_DENIED', 'CLAIM_PARTIAL_PAID' ) then
                    for y in (
                        select
                            nvl(service_type, 'HSA')  service_type,
                            nvl(c.denied_amount, 0)   denied_amount,
                            nvl(c.claim_pending, 0)   claim_pending,
                            nvl(c.claim_paid, 0)      claim_paid,
                            nvl(c.approved_amount, 0) approved_amount,
                            c.pers_id
                        from
                            claimn c
                        where
                                claim_id = x.entity_id
                            and x.entity_type = 'CLAIMN'
                    ) loop
                        pc_notification2.set_sms_token('CLAIM_ID', x.entity_id, l_notif_id);
                            -- Added by Swamy for Prod Issue Ticket#11191
                        l_service_type := y.service_type;
                        if l_service_type = 'HSA' then
                            for k in (
                                select
                                    account_type
                                from
                                    account
                                where
                                    pers_id = y.pers_id
                            ) loop
                                l_service_type := k.account_type;
                            end loop;
                        end if;

                        pc_notification2.set_sms_token('PLAN_TYPE', l_service_type, l_notif_id);   -- Added by Swamy for Prod Issue Ticket#11191
                    --PC_NOTIFICATION2.SET_SMS_TOKEN ('PLAN_TYPE',Y.service_type,l_notif_id);
                        if x.event_name = 'CLAIM_PROCESSED' then
                            pc_notification2.set_sms_token('CLAIM_AMOUNT', y.claim_paid, l_notif_id);
                            pc_notification2.set_sms_token('PROCESS_DATE', x.process_date, l_notif_id);
                        elsif x.event_name = 'CLAIM_PARTIAL_PAID' then
                            pc_notification2.set_sms_token('PROCESSED_AMT',
                                                           format_money(y.approved_amount),
                                                           l_notif_id);
                            pc_notification2.set_sms_token('DENIED_AMT',
                                                           format_money(y.denied_amount),
                                                           l_notif_id);
                        end if;

                    end loop;
                end if;

                update sms_notifications
                set
                    sms_status = 'READY'
                where
                    notification_id = l_notif_id;
        -- For triggering SMS to old email
        -- Added by Swamy for Ticket#9774
                if
                    upper(x.verified_phone_type) = 'MOBILE'
                    and upper(x.event_name) = 'PHONE'
                then
                    pc_log.log_error('PROCESS_EVENT old email id loop  ', x.email);
                    for xx in (
                        select
                            phone_no
                        from
                            online_user_security_history oh1
                        where
                                oh1.pers_id = x.pers_id
                            and user_id <> - 1
                            and oh1.change_id = (
                                select
                                    max(change_id)
                                from
                                    online_user_security_history oh2
                                where
                                        oh2.pers_id = oh1.pers_id
                                    and oh2.phone_no is not null
                            )
                    ) loop
                        pc_log.log_error('PROCESS_EVENT old phone no loop  ', xx.phone_no);
                        pc_notification2.insert_sms_notifications(
                            p_acc_id          => x.acc_id,
                            p_phone_number    => xx.phone_no,
                            p_sms_text        => x.template_body,
                            p_event_name      => x.event_name,
                            x_notification_id => l_notif_id
                        );

                        update sms_notifications
                        set
                            sms_status = 'READY'
                        where
                            notification_id = l_notif_id;

                    end loop;

                end if;

                update event_notifications
                set
                    processed_flag = 'Y',
                    phone_number = x.phone_number
                where
                    event_id = x.event_id;

            else
                update event_notifications
                set
                    processed_flag = 'E',
                    error_message = 'Either mobile no is invalid or it is landline phone'
                where
                    event_id = x.event_id;

            end if;

        end loop;

    end process_events;

    procedure insert_sms_notifications (
        p_acc_id          in number default null,
        p_phone_number    in varchar2,
        p_sms_text        in varchar2,
        p_event_name      in varchar2    -- Added by Swamy on 11/Feb/2020 for Ticket#8722
        ,
        x_notification_id out number
    ) is
    begin
        if p_phone_number is not null then
            insert into sms_notifications (
                notification_id,
                phone_number,
                sms_text,
                acc_id,
                sms_status,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                event_name          -- Added by Swamy on 11/Feb/2020 for Ticket#8722
            ) values ( notification_seq.nextval,
                       p_phone_number,
                       p_sms_text,
                       p_acc_id,
                       'OPEN',
                       sysdate,
                       0,
                       sysdate,
                       0,
                       p_event_name ) returning notification_id into x_notification_id;    --  P_EVENT_NAME Added by Swamy on 11/Feb/2020 for Ticket#8722
        end if;
    end insert_sms_notifications;

    procedure set_sms_token (
        p_token    in varchar2,
        p_string   in varchar2,
        p_notif_id in number
    ) is
    begin
        update sms_notifications
        set
            sms_text = replace(sms_text, '<<'
                                         || p_token
                                         || '>>', p_string)
        where
            notification_id = p_notif_id;

    end set_sms_token;

    procedure insert_events (
        p_acc_id      in number,
        p_pers_id     in number,
        p_event_name  in varchar2,
        p_entity_type in varchar2,
        p_entity_id   in number,
        p_ssn         in varchar2 default null
    ) is

        x_sms_template_name     map_notification_events.sms_template_name%type;
        x_email_template_name   map_notification_events.email_template_name%type;
        l_event_type            event_notifications.event_type%type;
        l_event_desc            lookups.description%type;
        l_acc_num               account.acc_num%type;
        l_pers_id               person.pers_id%type := p_pers_id;
        l_email                 event_notifications.email%type;
        l_template_name         event_notifications.template_name%type;
        l_subscribe_to_email    alert_preferences.subscribe_to_email%type;
        l_subscribe_to_sms      alert_preferences.subscribe_to_sms%type;
        l_acc_id                account.acc_id%type := p_acc_id;
        l_event_count           number := 0;
        l_verified_phone_number user_security_info.verified_phone_number%type;
        x_return_status         varchar2(1) := 'S';
        x_error_message         varchar2(1000);
        l_exception exception;
        l_account_type          varchar2(25);
        l_flg_exists            varchar2(1) := 'N';
        l_ssn                   varchar2(100);
    begin
        pc_log.log_error('INSERT_EVENTS Begin p_acc_id := ', p_acc_id
                                                             || ' p_acc_id :='
                                                             || p_pers_id
                                                             || ' p_event_name :='
                                                             || p_event_name
                                                             || 'p_ssn :='
                                                             || p_ssn
                                                             || 'p_entity_id :='
                                                             || p_entity_id);

        if p_acc_id is not null
           or p_pers_id is not null
        or p_ssn is not null then
            for k in (
                select
                    nvl(a.subscribe_to_sms, 'N')   subscribe_to_sms,
                    nvl(a.subscribe_to_email, 'N') subscribe_to_email,
                    l.description,
                    acc.acc_num,
                    acc.acc_id,
                    acc.pers_id,
                    acc.account_type
                from
                    alert_preferences a,
                    lookups           l,
                    account           acc,
                    person            p
                where
                        a.event_name = l.lookup_code
                    and a.event_name = decode(p_event_name, 'CLAIM_PARTIAL_PAID', 'CLAIM_PROCESSED', p_event_name)
                    and a.ssn = nvl(p_ssn, a.ssn)
                    and acc.acc_id = nvl(p_acc_id, acc.acc_id)
                    and acc.pers_id = nvl(p_pers_id, acc.pers_id)
                    and acc.pers_id = p.pers_id
                    and a.ssn = replace(p.ssn, '-')
                    and acc.account_status = 1
                    and ( ( a.subscribe_to_sms in ( 'N', 'Y' ) )
                          or ( a.subscribe_to_email in ( 'N', 'Y' ) ) )
            )   -- Added by Swamy for Ticket#8604
	                --AND  (NVL(a.subscribe_to_sms,'N') = 'Y' OR NVL(a.subscribe_to_email,'N') = 'Y')) -- Commented by Swamy for Ticket#8604
             loop
                l_subscribe_to_sms := k.subscribe_to_sms;
                l_subscribe_to_email := k.subscribe_to_email;
                l_event_desc := k.description;
                l_acc_num := k.acc_num;
                l_acc_id := k.acc_id;
                l_pers_id := k.pers_id;
                l_account_type := k.account_type;
                l_event_count := l_event_count + 1;
            end loop;

        elsif
            p_acc_id is null
            and p_pers_id is null
            and p_ssn is null
        then
            -- raise exception
            x_return_status := 'E';
        end if;

        pc_log.log_error('INSERT_EVENTS :l_subscribe_to_email', l_subscribe_to_email);
        if
            nvl(l_subscribe_to_email, '@') = '@'
            and p_event_name in ( 'EMAIL', 'ADDRESS', 'PHONE', 'BANK_ACCOUNT' )
        then
            pc_log.log_error('INSERT_EVENTS', 'Inside default security block');
            l_subscribe_to_email := 'Y';
            l_event_count := l_event_count + 1;
            if nvl(p_acc_id, 0) = 0 then
                for j in (
                    select
                        acc_id,
                        acc_num
                    from
                        account
                    where
                        pers_id = p_pers_id
                ) loop
                    l_acc_id := j.acc_id;
                    l_acc_num := j.acc_num;
                end loop;
            else
                l_acc_id := p_acc_id;
            end if;

            l_pers_id := p_pers_id;
        end if;

        if l_event_count = 0 then
            x_return_status := 'E';
        -- no events to process
        else
            pc_notification2.get_notification_template(
                p_event_name          => p_event_name,
                p_sms_template_name   => x_sms_template_name,
                p_email_template_name => x_email_template_name,
                x_return_status       => x_return_status,
                x_error_message       => x_error_message
            );
        end if;

        pc_log.log_error('INSERT_EVENTS l_subscribe_to_email ', l_subscribe_to_email);
        pc_log.log_error('INSERT_EVENTS l_subscribe_to_sms ', l_subscribe_to_sms);
        for x in (
            select
                'EMAIL'               event_type,
                x_email_template_name template_name
            from
                dual
            where
                l_subscribe_to_email = 'Y'
            union
            select
                'SMS'               event_type,
                x_sms_template_name template_name
            from
                dual
            where
                l_subscribe_to_sms = 'Y'
        ) loop
            pc_log.log_error('INSERT_EVENTS calling INSERT_EVENT_NOTIFICATIONS x.event_type := ', x.event_type
                                                                                                  || ' p_event_name :='
                                                                                                  || p_event_name
                                                                                                  || ' l_acc_id :='
                                                                                                  || l_acc_id);

            pc_log.log_error('INSERT_EVENTS calling INSERT_EVENT_NOTIFICATIONS l_account_type := ', l_account_type);
            if
                l_account_type in ( 'HRA', 'FSA' )
                and ( p_event_name = 'CLAIM_DENIED' )
                and x.event_type = 'EMAIL'
            then
                pc_log.log_error('INSERT_EVENTS x.event_type := ', x.event_type
                                                                   || ' p_event_name :='
                                                                   || p_event_name);
            else
                pc_log.log_error('INSERT_EVENTS x.event_type := ', x.event_type
                                                                   || ' p_event_name :='
                                                                   || p_event_name);
                if p_event_name in ( 'EMAIL', 'ADDRESS', 'PHONE' ) then  -- Added by Swamy for Ticket#8609, main ticket#7920
                    l_ssn := replace(p_ssn, '-');
                    l_flg_exists := 'N';
               -- When Phone/email/address is changed, Person,online_users,user_security_ino tables get updated.
               -- So the trigger will fire thrice for the same account. Secondly, if the account has more than one plan type, ex FSA/HRA, then updating email/phone/address
               -- will update the tables person/online_users/user_security_info for EACH account type. so we are passing ssn into event_id column so as to uniquely identify the record
               -- inorder to avoid duplicate entries.
                    for m in (
                        select
                            1
                        from
                            event_notifications
                        where
                                event_name = p_event_name
                            and event_type = x.event_type
                            and processed_flag = 'N'
                            and entity_id = l_ssn
                    ) loop
                        l_flg_exists := 'Y';
                    end loop;

                else
                    l_flg_exists := 'N';
                    for m in (
                        select
                            1
                        from
                            event_notifications
                        where
                                acc_id = l_acc_id
                            and event_name = p_event_name
                            and event_type = x.event_type
                            and processed_flag = 'N'
                            and entity_id = p_entity_id
                    ) loop
                        l_flg_exists := 'Y';
                    end loop;

                    l_ssn := p_entity_id;
                end if;

                pc_log.log_error('INSERT_EVENTS l_flg_exists := ', l_flg_exists);
                if l_flg_exists = 'N' then
                    pc_notifications.insert_event_notifications(
                        p_event_name    => p_event_name,
                        p_event_type    => x.event_type --'EMAIL'
                        ,
                        p_event_desc    => l_event_desc,
                        p_entity_type   => p_entity_type,
                        p_entity_id     => nvl(l_ssn, l_acc_id) --  NVL(p_entity_id,l_acc_id)
                        ,
                        p_acc_id        => l_acc_id,
                        p_acc_num       => l_acc_num,
                        p_pers_id       => l_pers_id,
                        p_user_id       => 0,
                        p_email         => null,
                        p_template_name => x.template_name,
                        x_return_status => x_return_status,
                        x_error_message => x_error_message
                    );

                    if nvl(x_return_status, 'N') = 'E' then
                        raise l_exception;
                    end if;
                end if;

            end if;
             -- handle the x return status calls
        end loop;

    exception
        when l_exception then
            x_return_status := 'E';
            pc_log.log_error('INSERT_EVENTS ERREUR x_error_message', x_error_message);
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm(sqlcode);
            pc_log.log_error('INSERT_EVENTS Others x_error_message', x_error_message);
    end insert_events;

    procedure get_notification_template (
        p_event_name          in varchar2,
        p_sms_template_name   out varchar2,
        p_email_template_name out varchar2,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    ) is
    begin
        x_return_status := 'S';
        pc_log.log_error('GET_NOTIFICATION_TEMPLATE P_EVENT_NAME', p_event_name);
        for i in (
            select
                sms_template_name,
                email_template_name
            from
                map_notification_events
            where
                event_name = p_event_name
        ) loop
            p_sms_template_name := i.sms_template_name;
            p_email_template_name := i.email_template_name;
        end loop;

    exception
        when others then
            x_error_message := sqlerrm(sqlcode);
            x_return_status := 'E';
    end get_notification_template;

-- Function Added by Swamy for Ticket#7920(Alert Notification) Sprint 21
-- Function used to fetch the details of Service and Security related Notifications.
    function get_alert_preferences (
        p_ssn in varchar2
    ) return alert_pref_t
        pipelined
        deterministic
    is

        l_record             alert_pref_rec;
        l_ssn                person.ssn%type;
        l_subscribe_to_sms   alert_preferences.subscribe_to_sms%type;
        l_subscribe_to_email alert_preferences.subscribe_to_email%type;
        x_error_message      varchar2(2000);
        x_return_status      varchar2(1);
    begin
        pc_log.log_error('GET_ALERT_PREFERENCES p_ssn', p_ssn);
        for i in (
            select
                lookup_code,
                description
            from
                lookups
            where
                    lookup_name = 'ALERT_NOTIFICATION'
                and lookup_code not in ( 'CLAIM_PARTIAL_PAID' )
        ) loop
            l_subscribe_to_sms := null;
            l_subscribe_to_email := null;
            for j in (
                select
                    subscribe_to_sms,
                    subscribe_to_email
                from
                    alert_preferences
                where
                        ssn = p_ssn
                    and event_name = i.lookup_code
            ) loop
                l_subscribe_to_sms := j.subscribe_to_sms;
                l_subscribe_to_email := j.subscribe_to_email;
            end loop;
   -- In general for Claimns and security related alert the default value for eamil should be "Y", as mail should be sent by default.
            if i.lookup_code in ( 'CLAIM_DENIED', 'EMAIL', 'PHONE', 'ADDRESS', 'BANK_ACCOUNT' ) then
                l_subscribe_to_email := nvl(l_subscribe_to_email, 'Y');
            end if;

            l_record.subscribe_to_sms := nvl(l_subscribe_to_sms, 'N');
            l_record.subscribe_to_email := nvl(l_subscribe_to_email, 'N');
            l_record.lookup_code := i.lookup_code;
            l_record.lookup_description := i.description;
            if i.lookup_code in ( 'PAYROLL_CONTRB', 'ADDRESS' ) then
                l_record.order_by_flg := '1';
            elsif i.lookup_code in ( 'CLAIM_PROCESSED', 'EMAIL' ) then
                l_record.order_by_flg := '2';
            elsif i.lookup_code in ( 'CLAIM_DENIED', 'PHONE' ) then
                l_record.order_by_flg := '3';
            elsif i.lookup_code in ( 'TAX_STATEMENT', 'BANK_ACCOUNT' ) then
                l_record.order_by_flg := '4';
            end if;

            if i.lookup_code in ( 'PAYROLL_CONTRB', 'CLAIM_PROCESSED', 'CLAIM_DENIED', 'TAX_STATEMENT' ) then
                l_record.category := 'SERVICE';
            elsif i.lookup_code in ( 'ADDRESS', 'EMAIL', 'PHONE', 'BANK_ACCOUNT' ) then
                l_record.category := 'SECURITY';
            end if;

            pipe row ( l_record );
        end loop;

    exception
        when others then
            x_error_message := sqlerrm(sqlcode);
            x_return_status := 'E';
            pc_log.log_error('GET_ALERT_PREFERENCES Others ', x_error_message);
    end get_alert_preferences;

-- Procedure Added by Swamy for Ticket#7920(Alert Notification) Sprint 21
-- Procedure to insert the details of service and security notifications into alert_preferences table.
    procedure insert_alert_preferences (
        p_ssn                in varchar2,
        p_event_type         in varchar2_tbl,
        p_subscribe_to_sms   in varchar2_tbl,
        p_subscribe_to_email in varchar2_tbl,
        p_user_id            in number,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    ) is
 -- Variable Declaration
        l_exists varchar2(1) := 'N';
    begin
        pc_log.log_error('INSERT_ALERT_PREFERENCES Begin p_ssn := ', p_ssn
                                                                     || ' p_user_id :='
                                                                     || p_user_id);
        x_return_status := 'S';
        delete from alert_preferences
        where
            ssn = p_ssn;

        for i in 1..p_event_type.count loop
            insert into alert_preferences (
                ssn,
                event_name,
                subscribe_to_sms,
                subscribe_to_email,
                creation_date,
                created_by
            ) values ( p_ssn,
                       p_event_type(i),
                       p_subscribe_to_sms(i),
                       p_subscribe_to_email(i),
                       sysdate,
                       p_user_id );

        end loop;

    exception
        when others then
            x_error_message := sqlerrm(sqlcode);
            x_return_status := 'E';
            pc_log.log_error('INSERT_ALERT_PREFERENCES Others ', x_error_message);
    end insert_alert_preferences;

    function get_email_preference (
        p_ssn        in varchar2,
        p_event_name varchar2
    ) return varchar2 is
        l_email_flag varchar2(1) := 'Y';
    begin
        for x in (
            select
                nvl(p.subscribe_to_email, 'N') email_flag
            from
                alert_preferences p
            where
                    format_ssn(p.ssn) = p_ssn
                and p.event_name = p_event_name
                and nvl(p.subscribe_to_email, 'N') = 'N'
        ) loop
            l_email_flag := x.email_flag;
        end loop;

        return l_email_flag;
    end get_email_preference;

    procedure insert_audit_security_info (
        p_pers_id            in number,
        p_user_id            in varchar2,
        p_email              in varchar2,
        p_phone_no           in varchar2,
        p_new_email_phone_no in varchar2   -- Added by Swamy for Ticket#9774
    ) is
        l_user_id number;
    begin

-- user_id should be from online_users table and created_by is who actually modified the record.
-- Added by Joshi for Ticket#9776
        l_user_id := get_user_id(v('APP_USER'));
        pc_log.log_error('l_user_id from insert_audit_security_info', l_user_id);
        insert into online_user_security_history (
            change_id,
            pers_id,
            user_id,
            email,
            phone_no,
            created_by,
            creation_date,
            new_email_phone_no
        ) values ( change_id_seq.nextval,
                   p_pers_id,
                   p_user_id,
                   p_email,
                   p_phone_no,
                   nvl(l_user_id, p_user_id),
                   sysdate,
                   p_new_email_phone_no );

    end insert_audit_security_info;

    procedure er_qb_balances_report is

        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
        v_email        varchar2(4000) := 'corp.finance@sterlingadministration.com,oakland-it@sterlingadministration.com';
    begin
        l_html_message := '<html>
<head>
    <title>Employer QB Balances Report</title>
</head>
<body bgcolor="#FFFFFF" link="#000080">
    <table cellspacing="0" cellpadding="0" width="100%">
        <tr>
            <td>
                <p>Hi Team,<br> Here is the spreadsheet for the Employer QB Balances Report as of '
                          || to_char(
            last_day(add_months(
                trunc(sysdate, 'MM'),
                -1
            )),
            'MM/DD/YYYY'
        )
                          || '.</p>
				<p>Thanks</p>
				<br>
				<p><strong>Note:</strong> Do not reply to this email. If you have any inquiries, we kindly ask you to raise a ticket and assign it to the appropriate team.</p>	
            </td>
        </tr>
    </table>
</body>
</html>';

        l_sql := 'SELECT acc_num "Account Number"
                  ,   CHECK_AMOUNT  "CHECK AMOUNT"
              FROM ( SELECT  b.acc_num,SUM(nvl(CHECK_AMOUNT,0))  CHECK_AMOUNT
            FROM    COBRA_EMPLOYER_BALANCES_V a ,account b
                    WHERE  a.acc_id = b.acc_id  -- entrp_id = p_entrp_id
                    AND     TRANSACTION_DATE <= (to_date(TO_CHAR(LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE, ''MM''), -1)), ''MM/DD/YYYY''),''MM/DD/YYYY''))
                    group by b.acc_num) WHERE 1 = 1';
        mail_utility.report_emails('oracle@sterlingadministration.com',
                                   v_email,
                                   'ER_QB_Balances_'
                                   || to_char(
                          last_day(add_months(
                              trunc(sysdate, 'MM'),
                              -1
                          )),
                          'MMDDYYYY'
                      )
                                   || '.xls',
                                   l_sql,
                                   l_html_message,
                                   'Employer QB Balances Report for '
                                   || to_char(
                          last_day(add_months(
                              trunc(sysdate, 'MM'),
                              -1
                          )),
                          'MM/DD/YYYY'
                      ));

    exception
        when others then
            pc_log.log_error('ER_QB_Balances_report Error', sqlerrm);
    end er_qb_balances_report;

    procedure ee_qb_balances_report is

        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
        v_email        varchar2(4000) := 'corp.finance@sterlingadministration.com,oakland-it@sterlingadministration.com';
    begin
        l_html_message := '<html>
<head>
    <title>Employee QB Balances Report</title>
</head>
<body bgcolor="#FFFFFF" link="#000080">
    <table cellspacing="0" cellpadding="0" width="100%">
        <tr>
            <td>
                <p>Hi Team,<br> Here is the spreadsheet for the Employee QB Balances Report as of '
                          || to_char(
            last_day(add_months(
                trunc(sysdate, 'MM'),
                -1
            )),
            'MM/DD/YYYY'
        )
                          || '.</p>
				<p>Thanks</p>
				<br>
				<p><strong>Note:</strong> Do not reply to this email. If you have any inquiries, we kindly ask you to raise a ticket and assign it to the appropriate team.</p>	
            </td>
        </tr>
    </table>
</body>
</html>';

        l_sql := ' SELECT acc_num "Account Number", AMOUNT
				FROM (SELECT   acc_num, SUM( amount  )  AMOUNT
				  FROM balance_register A, ACCOUNT B
				  WHERE B.PERS_ID IS NOT NULL
				  AND A.REASON_CODE <> 4
				  AND  a.acc_id = b.acc_id
				  AND  B.ACCOUNT_TYPE = ''COBRA''
				  AND  TRUNC(fee_date) BETWEEN TRUNC(NVL(to_date(''01/01/2004'',''mm/dd/yyyy''),trunc(SYSDATE)))
									  AND to_date(TO_CHAR(LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE, ''MM''), -1)), ''MM/DD/YYYY''),''MM/DD/YYYY'')
				  and b.entrp_id is null
					group by acc_num) WHERE 1 = 1';
        mail_utility.report_emails('oracle@sterlingadministration.com',
                                   v_email,
                                   'EE_QB_Balances_'
                                   || to_char(
                          last_day(add_months(
                              trunc(sysdate, 'MM'),
                              -1
                          )),
                          'MMDDYYYY'
                      )
                                   || '.xls',
                                   l_sql,
                                   l_html_message,
                                   'Employee QB Balances Report for '
                                   || to_char(
                          last_day(add_months(
                              trunc(sysdate, 'MM'),
                              -1
                          )),
                          'MM/DD/YYYY'
                      ));

    exception
        when others then
            pc_log.log_error('EE_QB_Balances_report Error', sqlerrm);
    end ee_qb_balances_report;

    procedure daily_feedback_report is

        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
        v_email        varchar2(4000) := 'managers@sterlingadministration.com,oakland-it@sterlingadministration.com';
    begin
        l_html_message := '<html>
<head>
    <title>Daily Feedback Report</title>
</head>
<body bgcolor="#FFFFFF" link="#000080">
    <table cellspacing="0" cellpadding="0" width="100%">
                <p>Hi Team,<br> Here is the spreadsheet for the daily feedback report as of '
                          || to_char(
            trunc(sysdate - 1),
            'MMDDYYYY'
        )
                          || '.</p>
				<p>Thanks</p>			
    </table>
</body>
</html>';

        l_sql := 'SELECT Tax_id,name,IMPROVEMENT_COMMENT,EMAIL,PHONE,entity_type
   FROM (SELECT DISTINCT (Tax_id) Tax_id, e.Name name, f.IMPROVEMENT_COMMENT, f.EMAIL, f.PHONE, f.entity_type 
			FROM feedback f, enterprise e
			WHERE tax_id = entrp_code 
			AND skipped = ''No''
			AND TRUNC(submission_date) >= SYSDATE - 1 
			AND f.entity_type = ''E''
			UNION        
			SELECT DISTINCT (Tax_id) Tax_id, b.Agency_Name name, f.IMPROVEMENT_COMMENT, f.EMAIL, f.PHONE, f.entity_type 
			FROM feedback f, broker b
			WHERE tax_id = broker_lic 
			AND skipped = ''No''
			AND TRUNC(submission_date) >= SYSDATE - 1
			AND f.entity_type = ''B''
		) WHERE 1 = 1';
        mail_utility.report_emails('noreply@sterlingadministration.com',
                                   v_email,
                                   'Daily_feedback_report'
                                   || to_char(
                          trunc(sysdate - 1),
                          'MMDDYYYY'
                      )
                                   || '.xls',
                                   l_sql,
                                   l_html_message,
                                   'Daily feedback report for '
                                   || to_char(
                          trunc(sysdate - 1),
                          'MMDDYYYY'
                      ));

    exception
        when others then
            dbms_output.enable;
            dbms_output.put_line(sqlerrm);
    end daily_feedback_report;

end pc_notification2;
/


-- sqlcl_snapshot {"hash":"0e04ac01e8a7c81283b72504d711d203723aa1d5","type":"PACKAGE_BODY","name":"PC_NOTIFICATION2","schemaName":"SAMQA","sxml":""}