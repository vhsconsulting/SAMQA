-- liquibase formatted sql
-- changeset SAMQA:1754374148070 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\compliance_staging_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/compliance_staging_seq.sql:null:023b848ffd3365653ea17278f922ba0c498804c4:create

create sequence samqa.compliance_staging_seq minvalue 1 maxvalue 999999999 increment by 1 start with 394214 nocache noorder nocycle nokeep
noscale global;

