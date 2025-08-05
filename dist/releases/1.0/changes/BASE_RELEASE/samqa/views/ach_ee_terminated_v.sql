-- liquibase formatted sql
-- changeset SAMQA:1754374167250 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\ach_ee_terminated_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/ach_ee_terminated_v.sql:null:f3b0ff64a084a1883b3653fdc9e127053651b2b6:create

create or replace force editionable view samqa.ach_ee_terminated_v (
    group_id,
    email
) as
    select distinct
        group_id,
        b.email
    from
        ach_emp_detail_v a,
        online_users     b
    where
        entrp_id is null
        and a.group_id = b.find_key
        and trunc(transaction_date) >= trunc(sysdate + 3);

