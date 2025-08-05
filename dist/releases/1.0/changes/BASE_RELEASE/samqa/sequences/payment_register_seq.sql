-- liquibase formatted sql
-- changeset SAMQA:1754374149672 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\payment_register_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/payment_register_seq.sql:null:143c2bdf7d71010966de7ad0595a131b9483cfb8:create

create sequence samqa.payment_register_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 2045734 cache 20
noorder nocycle nokeep noscale global;

