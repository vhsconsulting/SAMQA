-- liquibase formatted sql
-- changeset SAMQA:1754373933344 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\scheduler_stage_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/scheduler_stage_n1.sql:null:c9dd68fcbf444e52006001857b3e35ef6657fe6e:create

create unique index samqa.scheduler_stage_n1 on
    samqa.scheduler_stage (
        scheduler_stage_id
    );

