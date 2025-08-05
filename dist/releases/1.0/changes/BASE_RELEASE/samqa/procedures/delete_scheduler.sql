-- liquibase formatted sql
-- changeset SAMQA:1754374143507 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\delete_scheduler.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/delete_scheduler.sql:null:c407995c0761b1e2e38226608097c04e98b7ec55:create

create or replace procedure samqa.delete_scheduler (
    p_scheduler_id in number
) is
begin
    delete from scheduler_details
    where
        scheduler_id = p_scheduler_id;

    delete from scheduler_details_stg
    where
        scheduler_id = p_scheduler_id;

    delete from scheduler_stage
    where
        scheduler_id = p_scheduler_id;

    delete from scheduler_master
    where
        scheduler_id = p_scheduler_id;

end;
/

