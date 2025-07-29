-- liquibase formatted sql
-- changeset SAMQA:1753779761152 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\compliance_staging_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/compliance_staging_seq.sql:null:f9339528076c0f3295a5cad4a6751439f291869c:create

create sequence samqa.compliance_staging_seq minvalue 1 maxvalue 999999999 increment by 1 start with 394154 nocache noorder nocycle nokeep
noscale global;

