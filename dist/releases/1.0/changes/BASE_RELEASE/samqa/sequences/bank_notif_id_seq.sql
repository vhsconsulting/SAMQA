-- liquibase formatted sql
-- changeset SAMQA:1754374147578 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\bank_notif_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/bank_notif_id_seq.sql:null:c1fcafd3501279dce462ca1b9bc727d79e0a70ef:create

create sequence samqa.bank_notif_id_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 321 cache 20 noorder
nocycle nokeep noscale global;

