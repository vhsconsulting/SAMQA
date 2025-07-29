-- liquibase formatted sql
-- changeset SAMQA:1753779760664 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\bank_notif_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/bank_notif_id_seq.sql:null:2aa3a95ff42ac7b68af2f8256feedf5da73b255f:create

create sequence samqa.bank_notif_id_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 281 cache 20 noorder
nocycle nokeep noscale global;

