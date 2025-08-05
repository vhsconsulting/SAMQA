-- liquibase formatted sql
-- changeset SAMQA:1754374149383 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\nacha_detail_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/nacha_detail_seq.sql:null:bdef25aa3043f4800f1a485e8ce2c839376a6aef:create

create sequence samqa.nacha_detail_seq minvalue 7000001 maxvalue 7999999 increment by 1 start with 7446742 cache 20 noorder cycle nokeep
noscale global;

