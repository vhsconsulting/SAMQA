-- liquibase formatted sql
-- changeset SAMQA:1754374148046 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\compliance_quote_lines_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/compliance_quote_lines_seq.sql:null:f7c0c48c4c6abb14a22f0f9359eebd138cf3d58b:create

create sequence samqa.compliance_quote_lines_seq minvalue 1 maxvalue 999999999 increment by 1 start with 455522 nocache noorder nocycle
nokeep noscale global;

