-- liquibase formatted sql
-- changeset SAMQA:1754374169467 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\brokreg_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/brokreg_v.sql:null:535c12d518262d9f9a8ea4dc0b6806f48886cbca:create

create or replace force editionable view samqa.brokreg_v (
    pers_id,
    reg_date,
    broker_id,
    bname
) as
    (
        select
            pers_id,
            reg_date,
            broker_id,
            pc_person.pers_fld(broker_id, 'full_name') as bname
        from
            account
    );

