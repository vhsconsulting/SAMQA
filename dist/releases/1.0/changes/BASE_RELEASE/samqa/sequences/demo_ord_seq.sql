-- liquibase formatted sql
-- changeset SAMQA:1754374148275 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\demo_ord_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/demo_ord_seq.sql:null:5001e00430ed6ef59d774937d93e961c297d0b22:create

create sequence samqa.demo_ord_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 31 cache 20 noorder nocycle
nokeep noscale global;

