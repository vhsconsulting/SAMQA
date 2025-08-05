-- liquibase formatted sql
-- changeset SAMQA:1754374148450 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\employer_deposit_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/employer_deposit_seq.sql:null:7f89ccbf79bea97e561c7b6ebdc999cedb64e0f8:create

create sequence samqa.employer_deposit_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 2601905 cache 20
noorder nocycle nokeep noscale global;

