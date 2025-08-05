-- liquibase formatted sql
-- changeset SAMQA:1754373933280 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\scheduler_details_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/scheduler_details_n2.sql:null:efa32b85314583434944a7174564f600ea2493f7:create

create index samqa.scheduler_details_n2 on
    samqa.scheduler_details (
        acc_id
    );

