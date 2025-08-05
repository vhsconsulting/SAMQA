-- liquibase formatted sql
-- changeset SAMQA:1754373930800 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\deposit_register_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/deposit_register_n3.sql:null:28864b008ad7d98fb6ebdc93a379f90dae1b2a6d:create

create index samqa.deposit_register_n3 on
    samqa.deposit_register ( to_date(
        trans_date, 'MM/DD/YYYY') );

