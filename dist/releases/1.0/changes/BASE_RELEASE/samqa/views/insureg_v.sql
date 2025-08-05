-- liquibase formatted sql
-- changeset SAMQA:1754374176514 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\insureg_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/insureg_v.sql:null:741eb14d3a9cb89edfcb2af8ff8916169f7b1b39:create

create or replace force editionable view samqa.insureg_v (
    pers_id,
    reg_date,
    insur_id,
    iname,
    plan_type_m,
    plan_type
) as
    (
        select
            a.pers_id,
            a.reg_date,
            i.insur_id,
            e.name                                as iname,
            pc_lookups.get_plan_type(i.plan_type) plan_type_m,
            i.plan_type
        from
            account    a,
            insure     i,
            enterprise e
        where
                a.pers_id = i.pers_id
            and i.insur_id = e.entrp_id
            and a.account_status <> 5
    );

