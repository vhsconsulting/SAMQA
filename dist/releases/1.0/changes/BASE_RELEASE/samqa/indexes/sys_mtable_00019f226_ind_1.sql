-- liquibase formatted sql
-- changeset SAMQA:1754373933387 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\sys_mtable_00019f226_ind_1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/sys_mtable_00019f226_ind_1.sql:null:883071e2971286ce4e585ade45885c238ae3c24d:create

create unique index samqa.sys_mtable_00019f226_ind_1 on
    samqa.sys_export_schema_01 (
        process_order,
        duplicate
    );

