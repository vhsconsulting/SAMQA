-- liquibase formatted sql
-- changeset SAMQA:1754374147288 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\schedule_det_fk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/schedule_det_fk.sql:null:326a5111e12dc392b26a66113c84a363241e6d4c:create

alter table samqa.scheduler_details
    add constraint schedule_det_fk
        foreign key ( scheduler_id )
            references samqa.scheduler_master ( scheduler_id )
        enable;

