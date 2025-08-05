-- liquibase formatted sql
-- changeset SAMQA:1754374177587 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\new_list_bill_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/new_list_bill_v.sql:null:11266235ae31b042763e8ad16a196bd136897381:create

create or replace force editionable view samqa.new_list_bill_v (
    group_id,
    acct_id,
    employer_contrib,
    employee_contrib,
    ee_fee_amount,
    er_fee_amount,
    first_name,
    last_name,
    er_acc_id,
    acc_id
) as
    select
        c.acc_num group_id,
        d.acc_num acct_id,
        0         employer_contrib,
        0         employee_contrib,
        0         ee_fee_amount,
        0         er_fee_amount,
        e.first_name,
        e.last_name,
        c.acc_id  er_acc_id,
        d.acc_id  acc_id
    from
        account c,
        account d,
        person  e
    where
        c.entrp_id is not null
        and d.pers_id = e.pers_id
        and c.entrp_id = e.entrp_id;

