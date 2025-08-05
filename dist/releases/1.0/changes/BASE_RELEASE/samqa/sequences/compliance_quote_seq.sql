-- liquibase formatted sql
-- changeset SAMQA:1754374148058 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\compliance_quote_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/compliance_quote_seq.sql:null:4cffb93ea8f5cf6dbcd46bcffd471dc5e1a462dd:create

create sequence samqa.compliance_quote_seq minvalue 1 maxvalue 999999999 increment by 1 start with 433037 nocache noorder nocycle nokeep
noscale global;

