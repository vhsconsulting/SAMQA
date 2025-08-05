-- liquibase formatted sql
-- changeset SAMQA:1754373933419 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\sys_mtable_00019f226_ind_4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/sys_mtable_00019f226_ind_4.sql:null:424b3f3f7ace4e28cf98c5b5e2d1ebbf51d28ebd:create

create index samqa.sys_mtable_00019f226_ind_4 on
    samqa.sys_export_schema_01 (
        base_process_order
    );

