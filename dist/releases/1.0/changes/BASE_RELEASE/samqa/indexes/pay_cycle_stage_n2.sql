-- liquibase formatted sql
-- changeset SAMQA:1754373932592 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\pay_cycle_stage_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/pay_cycle_stage_n2.sql:null:d1d38b397a786c14d32d8958945cc16bf9de0bbc:create

create index samqa.pay_cycle_stage_n2 on
    samqa.pay_cycle_stage (
        ben_plan_id
    );

