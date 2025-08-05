-- liquibase formatted sql
-- changeset SAMQA:1754374167204 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\accreg_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/accreg_v.sql:null:d35751a3b7023e74eade42071c742f9b3f133f4d:create

create or replace force editionable view samqa.accreg_v (
    pers_id,
    acc_id,
    reg_date,
    start_date,
    acc_num,
    birth_date,
    blocked_flag
) as
    select
        pen.pers_id                pers_id,
        acc.acc_id,
        acc.reg_date               reg_date,
        acc.start_date             start_date,
        acc.acc_num,
        pen.birth_date             birth_date,
        nvl(acc.blocked_flag, 'N') blocked_flag
    from
        account acc,
        person  pen
    where
            pen.pers_id = acc.pers_id
        and acc.account_status <> 5;

