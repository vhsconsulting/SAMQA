-- liquibase formatted sql
-- changeset SAMQA:1754374175214 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\hex_login_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/hex_login_v.sql:null:b7bc9f308c3f6154686228a869f5b9118265725a:create

create or replace force editionable view samqa.hex_login_v (
    first_name,
    middle_name,
    last_name,
    user_id,
    employer_name,
    email,
    account_list,
    pers_id,
    user_name,
    acc_num,
    acc_id,
    entrp_id
) as
    select
        b.first_name,
        b.middle_name,
        b.last_name,
        a.user_id,
        pc_entrp.get_entrp_name(b.entrp_id) employer_name,
        a.email,
        pc_account.get_hex_acc_list(b.ssn)  account_list,
        b.pers_id,
        a.user_name,
        c.acc_num,
        c.acc_id,
        b.entrp_id
    from
        online_users a,
        person       b,
        account      c
    where
            a.tax_id = replace(b.ssn, '-')
        and b.pers_id = c.pers_id;

