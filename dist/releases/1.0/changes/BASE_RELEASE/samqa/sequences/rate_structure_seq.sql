-- liquibase formatted sql
-- changeset SAMQA:1754374149824 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\rate_structure_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/rate_structure_seq.sql:null:5dfa41beea5c3434db5eabcebe9309c38ccf26f6:create

create sequence samqa.rate_structure_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 21 cache 20 noorder
nocycle nokeep noscale global;

