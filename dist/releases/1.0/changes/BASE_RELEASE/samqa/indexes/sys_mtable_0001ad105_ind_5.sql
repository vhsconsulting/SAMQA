-- liquibase formatted sql
-- changeset SAMQA:1754373933467 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\sys_mtable_0001ad105_ind_5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/sys_mtable_0001ad105_ind_5.sql:null:0ac34830e210074fed8eee1a3de898df0458e1fb:create

create index samqa.sys_mtable_0001ad105_ind_5 on
    samqa.sys_export_schema_02 (
        original_object_schema,
        original_object_name,
        partition_name
    );

