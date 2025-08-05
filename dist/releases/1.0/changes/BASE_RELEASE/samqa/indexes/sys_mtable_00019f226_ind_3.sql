-- liquibase formatted sql
-- changeset SAMQA:1754373933405 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\sys_mtable_00019f226_ind_3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/sys_mtable_00019f226_ind_3.sql:null:5aec91577e89a9502c3a27b16addd0a6d06f71f8:create

create index samqa.sys_mtable_00019f226_ind_3 on
    samqa.sys_export_schema_01 (
        object_schema,
        object_name,
        object_type,
        partition_name,
        subpartition_name
    );

