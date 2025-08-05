-- liquibase formatted sql
-- changeset SAMQA:1754374170973 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\contribution_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/contribution_v.sql:null:2223e8700129b7dc7307dd737e06c2b730b697c5:create

create or replace force editionable view samqa.contribution_v (
    check_amount,
    cc_number,
    acc_id,
    type
) as
    select
        sum(nvl(amount, 0) + nvl(amount_add, 0)) check_amount,
        cc_number,
        b.acc_id,
        'Employer'                               type
    from
        income  a,
        account b
    where
        contributor is not null
        and a.contributor = b.entrp_id
    group by
        cc_number,
        b.acc_id,
        trunc(fee_date)
    union all
    select
        sum(nvl(amount, 0) + nvl(amount_add, 0)) check_amount,
        cc_number,
        a.acc_id,
        'Individual'
    from
        income  a,
        account b,
        person  c
    where
        contributor is null
        and a.acc_id = b.acc_id
        and b.pers_id = c.pers_id
    group by
        cc_number,
        a.acc_id,
        trunc(fee_date);

