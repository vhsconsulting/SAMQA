-- liquibase formatted sql
-- changeset SAMQA:1754373933434 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\sys_mtable_00019f226_ind_6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/sys_mtable_00019f226_ind_6.sql:null:a7bba9bab9bee94f5b1d861a9111f4eead06348e:create

create index samqa.sys_mtable_00019f226_ind_6 on
    samqa.sys_export_schema_01 (
        seed
    );

