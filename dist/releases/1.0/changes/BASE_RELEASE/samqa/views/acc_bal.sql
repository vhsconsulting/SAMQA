-- liquibase formatted sql
-- changeset SAMQA:1754374166442 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\acc_bal.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/acc_bal.sql:null:61529ad21c13a90d006803054d4f103374c055b5:create

create or replace force editionable view samqa.acc_bal (
    change_num,
    acc_id,
    op_date,
    amount,
    op_code,
    cnum,
    note,
    cur_bal,
    tbl
) as
    (
        select
            change_num,
            acc_id,
            fee_date,
            amount + nvl(amount_add, 0),
            fee_code,
            cc_number,
            note,
            cur_bal,
            'I'
        from
            income
        union all
        select
            change_num,
            acc_id,
            pay_date,
            - amount,
            reason_code,
            to_char(pay_num),
            note,
            cur_bal,
            'P'
        from
            payment
    );

