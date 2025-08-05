-- liquibase formatted sql
-- changeset SAMQA:1754374149396 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\nacha_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/nacha_seq.sql:null:48f2bd44d8388c382cd6231344ba97cce98b05d3:create

create sequence samqa.nacha_seq minvalue 1 maxvalue 9999999999999999999999999 increment by 1 start with 21397 cache 20 noorder nocycle
nokeep noscale global;

