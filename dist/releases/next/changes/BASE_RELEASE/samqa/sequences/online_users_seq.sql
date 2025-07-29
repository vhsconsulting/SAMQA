-- liquibase formatted sql
-- changeset SAMQA:1753779762611 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\online_users_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/online_users_seq.sql:null:29e54a1b93276c340590ba1d27dc9143cdc921b2:create

create sequence samqa.online_users_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 624038 cache 20 noorder
nocycle nokeep noscale global;

