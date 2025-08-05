-- liquibase formatted sql
-- changeset SAMQA:1754373933272 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\scheduler_details_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/scheduler_details_n1.sql:null:71c7e02e518f9ea2c0f66cb5f3f910d3d9de9f53:create

create index samqa.scheduler_details_n1 on
    samqa.scheduler_details (
        scheduler_id
    );

