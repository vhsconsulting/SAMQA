create or replace force editionable view samqa.emails_one_min_v (
    from_address,
    to_address,
    subject,
    message_body,
    notification_id,
    from_name
) as
    select
        from_address,
        case
            when a.cc_address is null then
                to_address
            else
                to_address
                || ','
                || a.cc_address
        end                                                                                                                                       to_address
        ,
        subject,
        message_body,
        a.notification_id,
        decode(from_address, 'customer.service@sterlingadministration.com', 'Sterling Administration Customer Service', 'Sterling Administration Customer Service'
        ) from_name
    from
        email_notifications a
    where
            mail_status = 'READY'
        and ( subject like '%TD Ameritade Transfer Request%'
              or subject like '%Online TD Ameritade Transfer Request%' )
    union
    select
        from_address,
        case
            when a.cc_address is null then
                to_address
            else
                to_address
                || ','
                || a.cc_address
        end                                                                                                                                       to_address
        ,
        subject,
        message_body,
        a.notification_id,
        decode(from_address, 'customer.service@sterlingadministration.com', 'Sterling Administration Customer Service', 'Sterling Administration Customer Service'
        ) from_name
    from
        email_notifications a
    where
            mail_status = 'READY'
        and event in (
            select
                lookup_code
            from
                lookups
            where
                ( lookup_name = 'ALERT_NOTIFICATION'
                  and lookup_code <> 'TAX_STATEMENT' )
        )
    union
    select
        from_address,
        case
            when a.cc_address is null then
                to_address
            else
                to_address
                || ','
                || a.cc_address
        end                                                                                                                                       to_address
        ,
        subject,
        message_body,
        a.notification_id,
        decode(from_address, 'benefits@sterlingadministration.com', 'Sterling Administration Benefits', 'Sterling Administration Customer Service'
        ) from_name
    from
        email_notifications a
    where
            mail_status = 'READY'
        and template_name in ( 'EDI_DISCREPANCY_REPORT', 'EDI_FILE_NOTIFY' )
    union
    select
        from_address,
        case
            when a.cc_address is null then
                to_address
            else
                to_address
                || ','
                || a.cc_address
        end                                                                                                                                       to_address
        ,
        subject,
        message_body,
        a.notification_id,
        decode(from_address, 'customer.service@sterlingadministration.com', 'Sterling Administration Customer Service', 'Sterling Administration Customer Service'
        ) from_name
    from
        email_notifications a
    where
            mail_status = 'READY'
        and template_name in ( 'ER_APPROVE_BROKER_AUTHORIZE_REQUEST', 'BROKER_AUTHORIZE_REQUEST_TO_ER' )
    union
    select
        from_address,
        case
            when a.cc_address is null then
                to_address
            else
                to_address
                || ','
                || a.cc_address
        end                                                                                                                                       to_address
        ,
        subject,
        message_body,
        a.notification_id,
        decode(from_address, 'customer.service@sterlingadministration.com', 'Sterling Administration Customer Service', 'Sterling Administration Customer Service'
        ) from_name
    from
        email_notifications a
    where
            mail_status = 'READY'
        and template_name in ( 'APP_CORRECTION_TEMPLATE', 'ER_REMITTANCE_BANK_ADD_REQUEST' )
    union  -- Added by Swamy for Ticket#10978 
    select
        from_address,
        case
            when a.cc_address is null then
                to_address
            else
                to_address
                || ','
                || a.cc_address
        end                                                                                                                                       to_address
        ,
        subject,
        message_body,
        a.notification_id,
        decode(from_address, 'customer.service@sterlingadministration.com', 'Sterling Administration Customer Service', 'Sterling Administration Customer Service'
        ) from_name
    from
        email_notifications a
    where
            mail_status = 'READY'
        and event in ( 'INACTIVE_BANK_EMAIL_NOTIFICATIONS', 'VERIFICATION_FAILURE_BANK_EMAIL_NOTIFICATIONS', 'ACTIVE_BANK_EMAIL_NOTIFICATIONS'
        , 'RTO_POP_CAFETERIA_PLAN_EMAIL_TEMPLATE', 'RTO_POP_BASIC_EMAIL_TEMPLATE' )
    union -- Added by Joshi for 12396. GIACT Reminder email
    select
        from_address,
        case
            when a.cc_address is null then
                to_address
            else
                to_address
                || ','
                || a.cc_address
        end                                                                                                                                       to_address
        ,
        subject,
        message_body,
        a.notification_id,
        decode(from_address, 'customer.service@sterlingadministration.com', 'Sterling Administration Customer Service', 'Sterling Administration Customer Service'
        ) from_name
    from
        email_notifications a
    where
            mail_status = 'READY'
        and template_name in ( 'GIACT_REMINDER_PENDINGDOC_BANK', 'GIACT_REMINDER_CANCELLED_BANK' );


-- sqlcl_snapshot {"hash":"a99de907b6f0d5e4011c3812667c52b17774c9df","type":"VIEW","name":"EMAILS_ONE_MIN_V","schemaName":"SAMQA","sxml":""}