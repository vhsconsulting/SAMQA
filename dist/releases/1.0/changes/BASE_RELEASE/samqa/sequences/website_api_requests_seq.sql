-- liquibase formatted sql
-- changeset SAMQA:1754374150324 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\website_api_requests_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/website_api_requests_seq.sql:null:9659a9c307448bec6d97af7eec9d1cdc8d710727:create

create sequence samqa.website_api_requests_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 709 cache 20
noorder nocycle nokeep noscale global;

