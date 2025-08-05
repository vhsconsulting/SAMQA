-- liquibase formatted sql
-- changeset SAMQA:1754374148262 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\demo_images_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/demo_images_seq.sql:null:fcb809d76b06d3aa6019b177ce0e3b4d97ce01ec:create

create sequence samqa.demo_images_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 31 cache 20 noorder nocycle
nokeep noscale global;

