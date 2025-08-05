-- liquibase formatted sql
-- changeset SAMQA:1754374166095 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\plan_notices_bf.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/plan_notices_bf.sql:null:dc86ef96f5db3fc37ba1315544a08b87439ce1e8:create

create or replace editionable trigger samqa.plan_notices_bf before
    insert on samqa.plan_notices
    for each row
declare
    l_entrp_id number;
begin
   --Added by Karthe K S on 11/02/2015 for the Pier Ticket 2464
    for i in (
        select
            entrp_id
        from
            ben_plan_enrollment_setup
        where
            ben_plan_id = :new.entity_id
    ) loop
        l_entrp_id := i.entrp_id;
    end loop;

    :new.entrp_id := l_entrp_id;
end;
/

alter trigger samqa.plan_notices_bf enable;

