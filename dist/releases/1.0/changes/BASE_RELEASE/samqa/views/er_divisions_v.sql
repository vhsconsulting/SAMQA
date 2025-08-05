-- liquibase formatted sql
-- changeset SAMQA:1754374172948 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\er_divisions_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/er_divisions_v.sql:null:3530da2785af9c4f7d891e5a433e717bcbe51c09:create

create or replace force editionable view samqa.er_divisions_v (
    division_id,
    division_code,
    division_name,
    entrp_id,
    er_acc_num,
    ee_count
) as
    select
        division_id,
        a.division_code,
        a.division_name,
        a.entrp_id,
        pc_entrp.get_acc_num(a.entrp_id)                                      er_acc_num,
        pc_employer_divisions.get_employee_count(a.entrp_id, a.division_code) ee_count
    from
        employer_divisions a
    union
    select
        null,
        'NO_DIVISION',
        'No Division',
        entrp_id,
        pc_entrp.get_acc_num(a.entrp_id) er_acc_num,
        count(*)
    from
        person a
    where
    /*EXISTS
    ( SELECT * FROM EMPLOYER_DIVISIONS WHERE ENTRP_ID = A.ENTRP_ID
    )
    AND*/
        division_code is null
    group by
        entrp_id;

