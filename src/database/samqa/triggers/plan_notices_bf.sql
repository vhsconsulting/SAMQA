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


-- sqlcl_snapshot {"hash":"2bc0991f8ef6461e9bde5d65ad4c94a91ffc77ab","type":"TRIGGER","name":"PLAN_NOTICES_BF","schemaName":"SAMQA","sxml":""}