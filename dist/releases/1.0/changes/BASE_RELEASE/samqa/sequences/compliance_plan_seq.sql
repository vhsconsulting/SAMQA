-- liquibase formatted sql
-- changeset SAMQA:1753779761112 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\compliance_plan_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/compliance_plan_seq.sql:null:1f83de0ce08e4f664cc3d052884a8fc43393fc28:create

create sequence samqa.compliance_plan_seq minvalue 1 maxvalue 999999999 increment by 1 start with 405843 nocache noorder nocycle nokeep
noscale global;

