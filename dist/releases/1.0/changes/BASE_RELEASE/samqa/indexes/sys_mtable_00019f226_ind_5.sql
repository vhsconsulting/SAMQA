-- liquibase formatted sql
-- changeset SAMQA:1754373933419 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\sys_mtable_00019f226_ind_5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/sys_mtable_00019f226_ind_5.sql:null:7b0d36251c9453e03b60d4b6f08107dfcf2634dc:create

create index samqa.sys_mtable_00019f226_ind_5 on
    samqa.sys_export_schema_01 (
        original_object_schema,
        original_object_name,
        partition_name
    );

