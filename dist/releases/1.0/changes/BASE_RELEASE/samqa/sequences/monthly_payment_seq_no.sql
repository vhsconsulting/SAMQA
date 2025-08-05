-- liquibase formatted sql
-- changeset SAMQA:1754374149357 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\monthly_payment_seq_no.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/monthly_payment_seq_no.sql:null:067d2a6ef0c87181053754d95497bcbecfb0f8f9:create

create sequence samqa.monthly_payment_seq_no minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 4370 cache 20
noorder nocycle nokeep noscale global;

