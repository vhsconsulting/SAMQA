-- liquibase formatted sql
-- changeset SAMQA:1754374149734 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\plan_notice_stage_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/plan_notice_stage_seq.sql:null:18fe60c0439d2325e329dac8e7036e18a2d4711f:create

create sequence samqa.plan_notice_stage_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 1 cache 20 noorder
nocycle nokeep noscale global;

