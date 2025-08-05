-- liquibase formatted sql
-- changeset SAMQA:1754374149519 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\online_renewals_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/online_renewals_seq.sql:null:9bb482232713b6d9cd7327d5bb3c30cdaee3ecf7:create

create sequence samqa.online_renewals_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 1 cache 20 noorder
nocycle nokeep noscale global;

