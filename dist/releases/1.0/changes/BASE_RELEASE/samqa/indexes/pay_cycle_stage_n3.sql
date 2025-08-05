-- liquibase formatted sql
-- changeset SAMQA:1754373932601 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\pay_cycle_stage_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/pay_cycle_stage_n3.sql:null:e97c74d9951730958b7e5f1834a4b3b12a1764a9:create

create index samqa.pay_cycle_stage_n3 on
    samqa.pay_cycle_stage (
        batch_number
    );

