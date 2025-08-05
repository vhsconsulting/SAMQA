-- liquibase formatted sql
-- changeset SAMQA:1754374167637 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\ach_nacha_v_old.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/ach_nacha_v_old.sql:null:fd02744b70fc53df2f6b3bc15f1c152118e20628:create

create or replace force editionable view samqa.ach_nacha_v_old (
    transaction_id,
    status,
    acc_num,
    fee_name,
    amount,
    bank_routing_num,
    bank_acct_num,
    personfname,
    personlname,
    personaddress,
    personphone,
    employer,
    bank_acct_type,
    transaction_date,
    transaction_type
) as
    select
        at.transaction_id,
        at.status,
        at.acc_num,
        'ePayment'              reason_code,
        nvl(at.total_amount, 0) amount,
        at.bank_routing_num,
        at.bank_acct_num,
        p.first_name            personfname,
        p.last_name             personlname,
        p.address
        || '|'
        || p.city
        || '|'
        || p.state
        || '|'
        || p.zip                personaddress,
        p.phone_day             personphone,
        'N'                     employer,
        at.bank_acct_type,
        at.transaction_date,
        at.transaction_type
    from
        ach_transfer_v at,
        person         p
    where
            at.pers_id = p.pers_id
        and at.status in ( 1, 2 )
        and trunc(transaction_date) <= trunc(sysdate)
        and at.transaction_type = 'D'
        and nvl(at.total_amount, 0) > 0
    union
    select
        at.transaction_id,
        at.status,
        at.acc_num,
        'ePayment',
        nvl(at.total_amount, 0) amount,
        at.bank_routing_num,
        at.bank_acct_num,
        e.name                  empname,
        null,
        e.address
        || '|'
        || e.city
        || '|'
        || e.state
        || '|'
        || e.zip                empaddress,
        e.entrp_phones          as empphone,
        'Y'                     employer,
        at.bank_acct_type,
        at.transaction_date,
        at.transaction_type
    from
        ach_transfer_v at,
        enterprise     e
    where
            at.entrp_id = e.entrp_id
        and at.status in ( 1, 2 )
        and trunc(transaction_date) <= trunc(sysdate)
        and at.transaction_type = 'D'
        and nvl(at.total_amount, 0) > 0
    order by
        3,
        1;

