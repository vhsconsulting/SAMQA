-- liquibase formatted sql
-- changeset SAMQA:1754373932583 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\pay_cycle_stage_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/pay_cycle_stage_n1.sql:null:dc5b098408dbe2ee977b18ae822ebb08a0bea17c:create

create index samqa.pay_cycle_stage_n1 on
    samqa.pay_cycle_stage (
        enrollment_detail_id
    );

