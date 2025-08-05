-- liquibase formatted sql
-- changeset SAMQA:1754373933450 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\sys_mtable_0001ad105_ind_2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/sys_mtable_0001ad105_ind_2.sql:null:6dd20f85e9d04dfe26d3a369afc5154eafd755e2:create

create index samqa.sys_mtable_0001ad105_ind_2 on
    samqa.sys_export_schema_02 (
        object_schema,
        original_object_name,
        object_type
    );

