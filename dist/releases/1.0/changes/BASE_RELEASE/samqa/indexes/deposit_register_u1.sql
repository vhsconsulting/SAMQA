-- liquibase formatted sql
-- changeset SAMQA:1753779554487 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\deposit_register_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/deposit_register_u1.sql:null:9627995135df913b454f957e824721c8cd4df366:create

create unique index samqa.deposit_register_u1 on
    samqa.deposit_register (
        deposit_register_id
    );

