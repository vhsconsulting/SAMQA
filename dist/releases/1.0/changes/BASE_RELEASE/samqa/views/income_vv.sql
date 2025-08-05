-- liquibase formatted sql
-- changeset SAMQA:1754374176316 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\income_vv.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/income_vv.sql:null:0f01da895f3b24162a1a570d9bd85c757d09d91b:create

create or replace force editionable view samqa.income_vv (
    change_num,
    acc_id,
    fee_date,
    fee_code,
    amount,
    contributor,
    pay_code,
    cc_number,
    cc_code,
    cc_owner,
    cc_date,
    note
) as
    select
        change_num,
        acc_id,
        fee_date,
        fee_code,
        amount,
        contributor,
        pay_code,
        cc_number,
        cc_code,
        cc_owner,
        cc_date,
        note
    from
        income_v;

