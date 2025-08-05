-- liquibase formatted sql
-- changeset SAMQA:1754373933434 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\sys_mtable_0001ad105_ind_1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/sys_mtable_0001ad105_ind_1.sql:null:386995d6b76c9b504b9ad973809e3928a5539f73:create

create unique index samqa.sys_mtable_0001ad105_ind_1 on
    samqa.sys_export_schema_02 (
        process_order,
        duplicate
    );

