-- liquibase formatted sql
-- changeset SAMQA:1754374149420 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\news_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/news_seq.sql:null:d5207fe08f87cfc3d1d81a556c5350122d83398b:create

create sequence samqa.news_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 141 cache 20 noorder nocycle
nokeep noscale global;

