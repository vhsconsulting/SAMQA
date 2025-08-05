-- liquibase formatted sql
-- changeset SAMQA:1754374171745 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\ee_deposits_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/ee_deposits_v.sql:null:d270bc206fa52cd57cb0d773cae7c1ffbb428ad4:create

create or replace force editionable view samqa.ee_deposits_v (
    fee_date,
    acc_num,
    name,
    first_name,
    middle_name,
    last_name,
    entrp_id,
    er_acc_num,
    plan_type,
    list_bill,
    er_amount,
    ee_amount,
    ee_fee_amount,
    er_fee_amount,
    cc_number,
    account_type,
    division_code,
    division_name
) as
    select
        fee_date,
        b.acc_num,
        c.first_name
        || ' '
        || c.middle_name
        || ' '
        || c.last_name                         name,
        c.first_name,
        c.middle_name,
        c.last_name,
        c.entrp_id,
        pc_entrp.get_acc_num(a.contributor)    er_acc_num,
        a.plan_type,
        a.list_bill,
        nvl(a.amount, 0)                       er_amount,
        nvl(a.amount_add, 0)                   ee_amount,
        nvl(a.ee_fee_amount, 0)                ee_fee_amount,
        nvl(a.er_fee_amount, 0)                er_fee_amount,
        a.cc_number,
        b.account_type,
        c.division_code,
        pc_person.get_division_name(b.pers_id) division_name
    from
        income  a,
        account b,
        person  c
    where
            a.acc_id = b.acc_id
        and b.pers_id = c.pers_id
        and nvl(a.fee_code, -1) <> 12;

