-- liquibase formatted sql
-- changeset SAMQA:1754374150208 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\title_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/title_seq.sql:null:6a149a1cf10510efb36e016f0441b3e51d152101:create

create sequence samqa.title_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 45 cache 20 noorder nocycle
nokeep noscale global;

