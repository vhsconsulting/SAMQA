-- liquibase formatted sql
-- changeset SAMQA:1754374149408 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\name_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/name_seq.sql:null:0e81adf90aeb4653d169e7f731a557971e2dd277:create

create sequence samqa.name_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 21 cache 20 noorder nocycle nokeep
noscale global;

