-- liquibase formatted sql
-- changeset SAMQA:1754374148300 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\demo_prod_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/demo_prod_seq.sql:null:d21d57ede366eb83ca80cc7c4619de30b242213f:create

create sequence samqa.demo_prod_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 41 cache 20 noorder nocycle
nokeep noscale global;

