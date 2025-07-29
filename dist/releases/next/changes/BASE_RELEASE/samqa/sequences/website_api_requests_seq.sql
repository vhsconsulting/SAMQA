-- liquibase formatted sql
-- changeset SAMQA:1753779763379 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\website_api_requests_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/website_api_requests_seq.sql:null:f337cf3dfcf9ff933e1c1d19b1d48c95981a1bc3:create

create sequence samqa.website_api_requests_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 509 cache 20
noorder nocycle nokeep noscale global;

