-- liquibase formatted sql
-- changeset SAMQA:1754374147466 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\address_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/address_id_seq.sql:null:f36936bd3a9c12c3cac5859f9df790202e9f1643:create

create sequence samqa.address_id_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 3462 cache 20 noorder
nocycle nokeep noscale global;

