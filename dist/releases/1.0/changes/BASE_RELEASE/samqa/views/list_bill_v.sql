-- liquibase formatted sql
-- changeset SAMQA:1754374176688 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\list_bill_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/list_bill_v.sql:null:873806163b689863308d6f6997a7d4226303279d:create

create or replace force editionable view samqa.list_bill_v (
    group_id,
    acct_id,
    er_amount,
    ee_amount,
    ee_fee_amount,
    er_fee_amount,
    first_name,
    last_name,
    acc_id,
    group_acc_id,
    entrp_id,
    account_status
) as
    select
        group_id,
        acct_id,
        max(employer_contrib) er_amount,
        max(employee_contrib) ee_amount,
        max(ee_fee_amount)    ee_fee_amount,
        max(er_fee_amount)    er_fee_amount,
        first_name,
        last_name,
        acc_id,
        group_acc_id,
        entrp_id,
        account_status
    from
        (
            select
                group_id,
                acct_id,
                employer_contrib,
                employee_contrib,
                ee_fee_amount,
                er_fee_amount,
                first_name,
                last_name,
                acc_id,
                group_acc_id,
                entrp_id,
                account_status
            from
                ach_emp_detail_v
            union
            select
                c.acc_num group_id,
                d.acc_num acct_id,
                0         employer_contrib,
                0         employee_contrib,
                0         ee_fee_amount,
                0         er_fee_amount,
                e.first_name,
                e.last_name,
                d.acc_id,
                c.acc_id  group_acc_id,
                e.entrp_id,
                d.account_status
            from
                account c,
                account d,
                person  e
            where
                c.entrp_id is not null
                and d.pers_id = e.pers_id
                and c.entrp_id = e.entrp_id
        )
    group by
        group_id,
        acct_id,
        first_name,
        last_name,
        acc_id,
        group_acc_id,
        entrp_id,
        account_status;

