-- liquibase formatted sql
-- changeset SAMQA:1753779762863 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\quote_line_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/quote_line_id_seq.sql:null:6fa04778d37ae29da27995d7e2a351209be6c2fd:create

create sequence samqa.quote_line_id_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 114896 cache 20 noorder
nocycle nokeep noscale global;

