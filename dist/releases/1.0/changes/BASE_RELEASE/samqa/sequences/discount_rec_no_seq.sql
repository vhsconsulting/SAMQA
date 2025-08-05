-- liquibase formatted sql
-- changeset SAMQA:1754374148364 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\discount_rec_no_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/discount_rec_no_seq.sql:null:4d558288ada36eeb4ebbcaf0d31cf81724a5bfc7:create

create sequence samqa.discount_rec_no_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 6083 cache 20 noorder
nocycle nokeep noscale global;

