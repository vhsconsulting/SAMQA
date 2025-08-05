-- liquibase formatted sql
-- changeset SAMQA:1754373930816 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\deposit_register_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/deposit_register_n5.sql:null:460500bd2bddceea1cc951478210c30ec39600f9:create

create index samqa.deposit_register_n5 on
    samqa.deposit_register (
        orig_sys_ref,
        reconciled_flag
    );

