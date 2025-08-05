-- liquibase formatted sql
-- changeset SAMQA:1754374164314 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\website_api_requests.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/website_api_requests.sql:null:b99bcd99984453685b90b294f4f04d68078a3808:create

create table samqa.website_api_requests (
    request_id     number,
    batch_number   number,
    request_type   varchar2(100 byte),
    request_method varchar2(10 byte),
    request_body   clob,
    response_body  clob,
    processed_flag varchar2(100 byte),
    entity_id      number,
    entity_type    varchar2(100 byte),
    created_by     varchar2(100 byte),
    creation_date  date,
    bank_details   clob
);

alter table samqa.website_api_requests add primary key ( request_id )
    using index enable;

