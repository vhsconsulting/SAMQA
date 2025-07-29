-- liquibase formatted sql
-- changeset SAMQA:1753779761521 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\employer_deposit_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/employer_deposit_seq.sql:null:a0d7213962fbc15538b004b70092f633aa4c4ad9:create

create sequence samqa.employer_deposit_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 2601885 cache 20
noorder nocycle nokeep noscale global;

