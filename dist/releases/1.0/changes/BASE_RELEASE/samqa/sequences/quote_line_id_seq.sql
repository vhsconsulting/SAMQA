-- liquibase formatted sql
-- changeset SAMQA:1754374149786 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\quote_line_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/quote_line_id_seq.sql:null:be3db07cb266dd18aef0ffd51303e1a10991e68a:create

create sequence samqa.quote_line_id_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 114976 cache 20 noorder
nocycle nokeep noscale global;

