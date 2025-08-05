-- liquibase formatted sql
-- changeset SAMQA:1754374158955 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\giact_api_response_code.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/giact_api_response_code.sql:null:797576042cfbe38a9aa13910bf09fa022ddf485f:create

create table samqa.giact_api_response_code (
    gverify       varchar2(5 byte),
    gauthenticate varchar2(500 byte),
    gresult       varchar2(1 byte)
);

