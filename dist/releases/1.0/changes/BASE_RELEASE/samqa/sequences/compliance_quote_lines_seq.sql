-- liquibase formatted sql
-- changeset SAMQA:1753779761126 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\compliance_quote_lines_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/compliance_quote_lines_seq.sql:null:221e66e13124eddb6cbb3aa84a4167d425f24657:create

create sequence samqa.compliance_quote_lines_seq minvalue 1 maxvalue 999999999 increment by 1 start with 455395 nocache noorder nocycle
nokeep noscale global;

