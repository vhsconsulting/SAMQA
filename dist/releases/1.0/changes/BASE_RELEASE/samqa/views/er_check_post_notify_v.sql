-- liquibase formatted sql
-- changeset SAMQA:1754374172928 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\er_check_post_notify_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/er_check_post_notify_v.sql:null:84204bc7f9c96d3144be771d883063895ea078ca:create

create or replace force editionable view samqa.er_check_post_notify_v (
    acc_num,
    check_number,
    check_amount,
    check_date,
    name,
    entrp_contact,
    entrp_email,
    acc_id,
    ein
) as
    select
        b.acc_num,
        a.check_number,
        a.check_amount,
        to_char(a.check_date, 'MM/DD/YYYY') check_date,
        d.name,
        d.entrp_contact,
        nvl(
            pc_users.get_email(b.acc_num, null, null),
            replace(
                replace(
                    replace(d.entrp_email, ';', ','),
                    '/',
                    ','
                ),
                ' ',
                ''
            )
        )                                   entrp_email,
        b.acc_id,
        d.entrp_code
    from
        employer_deposits a,
        account           b,
        pay_type          c,
        enterprise        d
    where
                trunc(a.creation_date) = trunc(sysdate) - 4
            and a.entrp_id = b.entrp_id
        and a.pay_code not in ( 3, 4, 5, 6 )
        and a.pay_code = c.pay_code
        and a.entrp_id = d.entrp_id
        and exists (
            select
                *
            from
                income b
            where
                    a.list_bill = b.list_bill
                and a.entrp_id = b.contributor
        )
        and b.account_type = 'HSA'
        and a.check_amount > 0;

