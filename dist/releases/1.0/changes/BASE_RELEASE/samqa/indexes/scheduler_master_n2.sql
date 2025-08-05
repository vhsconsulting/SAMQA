-- liquibase formatted sql
-- changeset SAMQA:1754373933310 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\scheduler_master_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/scheduler_master_n2.sql:null:a387502f3add79494495f60c38bca147ace47854:create

create index samqa.scheduler_master_n2 on
    samqa.scheduler_master (
        contributor
    );

