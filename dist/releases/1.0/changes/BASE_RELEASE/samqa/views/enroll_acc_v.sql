-- liquibase formatted sql
-- changeset SAMQA:1754374172628 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\enroll_acc_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/enroll_acc_v.sql:null:d182a53bc48089b311e9871d45074e5846a8d101:create

create or replace force editionable view samqa.enroll_acc_v (
    user_name,
    acc_num,
    entrp_id,
    email,
    tax_id
) as
    select
        a.user_name,
        b.acc_num,
        b.entrp_id,
        a.email,
        a.tax_id
    from
        online_users a,
        account      b
    where
            a.find_key = b.acc_num
        and b.pers_id is null
        and a.emp_reg_type = '1';

