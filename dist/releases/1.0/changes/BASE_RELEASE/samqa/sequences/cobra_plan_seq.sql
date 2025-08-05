-- liquibase formatted sql
-- changeset SAMQA:1754374148019 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\cobra_plan_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/cobra_plan_seq.sql:null:83701b2ad28c72bddeac866228a31dbfd1f488bc:create

create sequence samqa.cobra_plan_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 78560 cache 20 noorder
nocycle nokeep noscale global;

