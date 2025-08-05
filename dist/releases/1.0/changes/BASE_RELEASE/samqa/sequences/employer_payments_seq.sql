-- liquibase formatted sql
-- changeset SAMQA:1754374148484 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\employer_payments_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/employer_payments_seq.sql:null:e750a0f8aa265a88e56eca6be02acefddbdd2c7b:create

create sequence samqa.employer_payments_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 4152356 cache 20
noorder nocycle nokeep noscale global;

