-- liquibase formatted sql
-- changeset SAMQA:1754373933387 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\sys_mtable_00019f226_ind_2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/sys_mtable_00019f226_ind_2.sql:null:8e7beb71b8430255cb9bbb6adf64984a2532ae67:create

create index samqa.sys_mtable_00019f226_ind_2 on
    samqa.sys_export_schema_01 (
        object_schema,
        original_object_name,
        object_type
    );

