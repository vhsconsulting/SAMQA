-- liquibase formatted sql
-- changeset SAMQA:1754373933482 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\sys_mtable_0001ad105_ind_6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/sys_mtable_0001ad105_ind_6.sql:null:7e0f202bad7c06ed1b41e7909a78d3dbb8a1fb00:create

create index samqa.sys_mtable_0001ad105_ind_6 on
    samqa.sys_export_schema_02 (
        seed
    );

