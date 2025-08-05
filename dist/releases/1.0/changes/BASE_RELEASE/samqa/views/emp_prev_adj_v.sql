-- liquibase formatted sql
-- changeset SAMQA:1754374172159 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\emp_prev_adj_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/emp_prev_adj_v.sql:null:3dd0271b76a67e1451f8a3fc1524ff820b41223b:create

create or replace force editionable view samqa.emp_prev_adj_v (
    entrp_id,
    group_acc_num,
    name,
    first_name,
    middle_name,
    last_name,
    acc_num,
    fee_date,
    emp_deposit,
    subscr_deposit,
    ee_fee_deposit,
    er_fee_deposit
) as
    select
        a.contributor         entrp_id,
        (
            select
                acc_num
            from
                account
            where
                entrp_id = a.contributor
        )                     group_acc_num,
        c.title
        || ' '
        || c.first_name
        || ' '
        || c.middle_name
        || ' '
        || c.last_name        name,
        c.first_name,
        c.middle_name,
        c.last_name,
        acc_num,
        fee_date,
        nvl(amount, 0)        emp_deposit,
        nvl(amount_add, 0)    subscr_deposit,
        nvl(ee_fee_amount, 0) ee_fee_deposit,
        nvl(er_fee_amount, 0) er_fee_deposit
    from
        income  a,
        account b,
        person  c
    where
            a.acc_id = b.acc_id
        and c.pers_id = b.pers_id
        and nvl(a.fee_code, '-1') = '130';

