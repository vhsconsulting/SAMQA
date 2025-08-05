-- liquibase formatted sql
-- changeset SAMQA:1754374149495 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\online_enroll_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/online_enroll_seq.sql:null:1b049b4e7daf42ea3fa3e0fcf0787a9cce832be9:create

create sequence samqa.online_enroll_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 1430227 cache 20 noorder
nocycle nokeep noscale global;

