-- liquibase formatted sql
-- changeset SAMQA:1754374168411 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\bank_transfer_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/bank_transfer_v.sql:null:ceb69bd0ca88ee988002bbea376f010c3789c4f2:create

create or replace force editionable view samqa.bank_transfer_v (
    transaction_id,
    status,
    acc_num,
    reason_code,
    amount,
    bank_routing_num,
    bank_acct_num,
    empname,
    empaddress,
    empphone,
    personfname,
    personlname,
    personaddress,
    personphone
) as
    select
        at.transaction_id,
        at.status,
        at.acc_num,
        at.reason_code,
        at.amount,
        at.bank_routing_num,
        at.bank_acct_num,
        e.name          empname,
        ( e.address
          || '|'
          || '|'
          || e.city
          || '|'
          || e.state
          || '|'
          || e.zip )      empaddress,
        e.contact_phone empphone,
        p.first_name    personfname,
        p.last_name     personlname,
        ( p.address
          || '|'
          || '|'
          || p.city
          || '|'
          || p.state
          || '|'
          || p.zip )      personaddress,
        p.daytime_phone personphone
       --, substr(at.bank_acct_type,1,1)  bank_acct_type
    from
        ach_transfer_v at,
        myemploy       e,
        myperson_pl    p
    where
            e.group_n = at.acc_num
        and p.group_n = e.group_n
        and transaction_date <= sysdate
        and at.acc_num = p.group_n
        and status in ( 1, 2 )
        and at.transaction_type = 'C'
        and at.amount > 0
    union
    select
        at.transaction_id,
        at.status,
        at.acc_num,
        at.reason_code,
        at.amount,
        at.bank_routing_num,
        at.bank_acct_num,
        null            as empname,
        null            empaddress,
        null            empphone,
        p.first_name    personfname,
        p.last_name     personlname,
        ( p.address
          || '|'
          || '|'
          || p.city
          || '|'
          || p.state
          || '|'
          || p.zip )      personaddress,
        p.daytime_phone personphone
       --, substr(at.bank_acct_type,1,1)  bank_acct_type
    from
        ach_transfer_v at,
        myperson_pl    p
    where
            p.acc_num = at.acc_num
        and transaction_date <= sysdate
        and status in ( 1, 2 )
        and at.transaction_type = 'C'
        and at.amount > 0
    order by
        3,
        1;

