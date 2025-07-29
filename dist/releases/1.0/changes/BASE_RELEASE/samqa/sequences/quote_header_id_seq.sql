-- liquibase formatted sql
-- changeset SAMQA:1753779762850 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\quote_header_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/quote_header_id_seq.sql:null:e7ab2ca99a421f4c534c492e3a48c873c45c3320:create

create sequence samqa.quote_header_id_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 134825 cache 20 noorder
nocycle nokeep noscale global;

