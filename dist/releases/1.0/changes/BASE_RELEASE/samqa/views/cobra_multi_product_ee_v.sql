-- liquibase formatted sql
-- changeset SAMQA:1754374170850 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\cobra_multi_product_ee_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/cobra_multi_product_ee_v.sql:null:7408715e47f55e9d25e71321f45c0134151c1f0e:create

create or replace force editionable view samqa.cobra_multi_product_ee_v (
    first_name,
    last_name,
    ssn,
    acc_num,
    start_date,
    pers_id,
    entrp_id,
    email,
    employer,
    css,
    other_account,
    account_type,
    other_acc_id,
    account_status
) as
    select distinct
        a.first_name,
        a.last_name,
        a.ssn,
        b.acc_num,
        b.start_date,
        a.pers_id,
        a.entrp_id,
        pc_users.get_email(b.acc_num, b.acc_id, a.pers_id)      email,
        pc_entrp.get_entrp_name(c.entrp_id)                     employer,
        pc_sales_team.get_cust_srvc_rep_name_for_er(c.entrp_id) css,
        d.acc_num                                               other_account,
        d.account_type,
        d.acc_id                                                other_acc_id,
        b.account_status
    from
        person  a,
        account b,
        person  c,
        account d
    where
            a.pers_id = b.pers_id
        and b.account_type = 'COBRA'
        and a.ssn = c.ssn
        and c.pers_id = d.pers_id
        and d.account_type <> 'COBRA'
        and ( a.ssn not like ( '000%' )
              and a.ssn not like ( '111%' )
              and a.ssn not like ( '999%' ) );

