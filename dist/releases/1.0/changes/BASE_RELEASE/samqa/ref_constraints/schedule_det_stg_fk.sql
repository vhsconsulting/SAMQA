-- liquibase formatted sql
-- changeset SAMQA:1754374147301 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\schedule_det_stg_fk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/schedule_det_stg_fk.sql:null:60241f7a4c699eed977e04ea8b3f0eb46e47c3d6:create

alter table samqa.scheduler_details_stg
    add constraint schedule_det_stg_fk
        foreign key ( scheduler_id )
            references samqa.scheduler_master ( scheduler_id )
        enable;

