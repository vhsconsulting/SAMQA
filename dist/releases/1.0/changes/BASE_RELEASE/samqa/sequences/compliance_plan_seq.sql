-- liquibase formatted sql
-- changeset SAMQA:1754374148033 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\compliance_plan_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/compliance_plan_seq.sql:null:2c74088582e668659f0479355426bd4ff4886dc6:create

create sequence samqa.compliance_plan_seq minvalue 1 maxvalue 999999999 increment by 1 start with 405903 nocache noorder nocycle nokeep
noscale global;

