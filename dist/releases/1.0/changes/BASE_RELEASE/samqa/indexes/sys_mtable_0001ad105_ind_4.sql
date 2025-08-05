-- liquibase formatted sql
-- changeset SAMQA:1754373933467 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\sys_mtable_0001ad105_ind_4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/sys_mtable_0001ad105_ind_4.sql:null:3f539f78f7830426000842da2cd4115935001c34:create

create index samqa.sys_mtable_0001ad105_ind_4 on
    samqa.sys_export_schema_02 (
        base_process_order
    );

