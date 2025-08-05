-- liquibase formatted sql
-- changeset SAMQA:1754374146231 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\send_courtesy_notice1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/send_courtesy_notice1.sql:null:b41b90c2a34b99afccb7db662d544ce042f50ccf:create

create or replace procedure samqa.send_courtesy_notice1 is

    v_entrp_id          number;
    v_description       varchar2(3200);
    v_template_name     varchar2(3200);
    v_template_subject  varchar2(3200);
    v_template_body     varchar2(32000);
    v_invoice_id        number;
    l_notif_id          number;
    l_email             varchar2(4000);
    num_tbl             pc_notifications.number_tbl;
    l_send_notification varchar2(1) := 'Y';
begin
    for xx in (
        select
            ar.invoice_id,
            ar.invoice_due_date,
            trunc(sysdate) - trunc(ar.invoice_due_date)      invoice_age,
            ar.entity_id,
            ar.entity_type,
            ar.acc_id,
            ar.invoice_reason,
            case
                when ar.plan_type in ( 'HRA', 'FSA', 'HRAFSA', 'FSAHRA' ) then
                    'HRAFSA'
                when ar.plan_type = 'COBRA' then
                    'COBRA'
                else
                    'COMPLIANCE'
            end                                              product_code,
            case
                when ar.invoice_reason = 'FEE'     then
                    'FEE_BILLING'
                when ar.invoice_reason = 'FUNDING' then
                    'FUND_BILLING'
                when ar.invoice_reason = 'CLAIM'   then
                    'CLAIM_BILLING'
            end                                              billing_code,
            pc_lookups.get_meaning(
                pc_account.get_account_type(ar.acc_id),
                'ACCOUNT_TYPE'
            )                                                account_type,
            ip.invoice_frequency,
            pc_entrp.get_entrp_name(ar.entity_id)
            || '('
            || pc_entrp.get_acc_num(ar.entity_id)
            || ')'                                           company_name -- Added by Joshi for 10974
            ,
            'COURTESY_NOTICE1'                               description,
            nt.template_name,
            nt.template_subject,
            template_body,
            ' accountsreceivable@sterlingadministration.com' from_address,
            to_address,
            nt.cc_address
        from
            ar_invoice            ar,
            invoice_parameters    ip,
            notification_template nt
        where
                ar.status = 'PROCESSED'
            and ar.invoice_reason in ( 'FEE', 'FUNDING', 'CLAIM' )
            and ar.invoice_reason = ip.invoice_type
            and ar.rate_plan_id = ip.rate_plan_id
            and nvl(ip.division_code, '-1') = nvl(ar.division_code, '-1')
            and ip.status = 'A'
            and nt.notif_template_id = 865
            and ip.send_invoice_reminder = 'Y'
            and ar.entity_type = 'EMPLOYER'
            and ar.invoice_id in (
                select
                    ar.invoice_id  --  nvl(GA.GENERATE_COMBINED_STMT,'N'), GA.GA_ID
                from
                    ar_invoice    ar, account       acc, general_agent ga
                where
                        ar.acc_id = acc.acc_id
                    and ar.status = 'PROCESSED'
                    and ar.invoice_reason in ( 'FEE', 'FUNDING', 'CLAIM' )
                                                                    --AND AR.MAILED_DATE IS NULL
                    and nvl(ga.generate_combined_stmt, 'N') = 'N'
                    and trunc(ar.approved_date) >= to_date('04/01/2023', 'mm/dd/yyyy')
                    and trunc(invoice_due_date) + 11 <= to_date('06/29/2023', 'mm/dd/yyyy')
                    and acc.ga_id = ga.ga_id (+)
                    and not exists (
                        select
                            *
                        from
                            ar_invoice_notifications ari
                        where
                            ari.invoice_id = ar.invoice_id
                    )
            )
    ) loop

		          -- Added by Joshi for 9830. For FSA/HRA invoice reminder should not go if GA Monthly
                  -- invoice statement is generated for the invoice
        l_send_notification := 'Y';

                  --  IF XX.PRODUCT_CODE = 'HRAFSA' AND XX.billing_code = 'FEE_BILLING' THEN
                  -- Commented above and added below by Joshi for 10744. for cobra also notification should not be sent
        if (
            xx.product_code = 'HRAFSA'
            and xx.billing_code = 'FEE_BILLING'
        )
        or (
            xx.account_type = 'COBRA'
            and xx.invoice_frequency = 'MONTHLY'
        ) then
            for y in (
                select
                    nvl(generate_combined_stmt, 'N') generate_combined_stmt_flag
                from
                    general_agent ga,
                    account       a
                where
                        a.acc_id = xx.acc_id
                    and a.ga_id = ga.ga_id
            ) loop
                if y.generate_combined_stmt_flag = 'Y' then
                    l_send_notification := 'N';
                end if;
            end loop;

        end if;

        dbms_output.put_line('v_invoice_id: '
                             || v_invoice_id
                             || 'l_send_notification:'
                             || l_send_notification);

                 -- Added by Joshi for 9830.
        if l_send_notification = 'Y' then
            for xxx in (
                select
                    listagg(email, ',') within group(
                    order by
                        email
                    ) email
                from
                    table ( pc_contact.get_notify_emails(
                        pc_entrp.get_tax_id(xx.entity_id),
                        xx.billing_code,
                        xx.product_code,
                        xx.invoice_id
                    ) )
            ) loop
                l_email := substr(xxx.email, 1, 4000);
            end loop;

            for xxx in (
                select
                    user_id
                from
                    online_users
                where
                        emp_reg_type = 2
                    and tax_id = pc_entrp.get_tax_id(xx.entity_id)
                    and user_status <> 'D'
            ) loop
                num_tbl(num_tbl.count + 1) := xxx.user_id;
            end loop;

            pc_notifications.add_notify_users(num_tbl, l_notif_id);
            if nvl(l_email, xx.to_address) is not null then
                pc_notifications.insert_notifications(
                    p_from_address    => xx.from_address,
                    p_to_address      => nvl(l_email, xx.to_address),
                    p_cc_address      => xx.cc_address,
                    p_subject         => replace(
                        replace(
                            replace(xx.template_subject, '<<PRODUCT>>', xx.account_type),
                            '<<INVOICE_DUE_DAY>>',
                            xx.invoice_age
                        ),
                        '<<COMPANY_NAME>>',
                        xx.company_name
                    ) -- commented above and added line by Joshi for  10974
                    ,
                    p_message_body    => xx.template_body,
                    p_acc_id          => xx.acc_id,
                    p_user_id         => 0,
                    x_notification_id => l_notif_id
                );

                pc_invoice.insert_inv_notif(
                    p_invoice_id      => xx.invoice_id,
                    p_invoice_age     => xx.invoice_age,
                    p_notif_type      => xx.description,
                    p_email           => nvl(l_email, xx.to_address),
                    p_notification_id => l_notif_id,
                    p_template_name   => xx.template_name
                );

            end if;

        end if; -- Added by Joshi for 9830.

    end loop;
end;
/

