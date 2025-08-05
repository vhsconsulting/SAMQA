-- liquibase formatted sql
-- changeset SAMQA:1754374178210 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\persreg_vv.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/persreg_vv.sql:null:a77553c2927e8bc1a07eff1d5b9e7a9a1f30fb1d:create

create or replace force editionable view samqa.persreg_vv (
    pers_id,
    reg_date,
    start_date,
    acc_num,
    plan,
    birth_date,
    city,
    county,
    broker_id,
    ename
) as
    select
        pen.pers_id    pers_id,
        acc.reg_date   reg_date,
        acc.start_date start_date,
        acc.acc_num,
        pln.plan_name  plan,
        pen.birth_date birth_date,
        pen.city       city,
        pen.county     county,
        acc.broker_id  broker_id,
        ene.name       ename
    from
        account    acc,
        person     pen,
        insure     ine,
        plans      pln,
        enterprise ene
    where
            pen.pers_id = acc.pers_id
        and acc.account_status <> 5
        and pen.pers_id = ine.pers_id
        and acc.plan_code = pln.plan_code
        and ine.insur_id = ene.entrp_id;

