-- liquibase formatted sql
-- changeset SAMQA:1753779760553 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\address_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/address_id_seq.sql:null:47d52591395697aad25e4da85d0e4b12a5300f0a:create

create sequence samqa.address_id_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 3442 cache 20 noorder
nocycle nokeep noscale global;

