-- liquibase formatted sql
-- changeset SAMQA:1754373933450 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\sys_mtable_0001ad105_ind_3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/sys_mtable_0001ad105_ind_3.sql:null:b0ab0a75e10cb89c4fb3a6fb966068c4a846e406:create

create index samqa.sys_mtable_0001ad105_ind_3 on
    samqa.sys_export_schema_02 (
        object_schema,
        object_name,
        object_type,
        partition_name,
        subpartition_name
    );

