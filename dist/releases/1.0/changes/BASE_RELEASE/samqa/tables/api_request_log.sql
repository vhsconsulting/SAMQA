-- liquibase formatted sql
-- changeset SAMQA:1754374151638 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\api_request_log.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/api_request_log.sql:null:b29c75ace18d556fcea323300c7c0c42da7b692b:create

create table samqa.api_request_log (
    request_log_id              number,
    api_name                    varchar2(10 byte),
    request_timestamp           varchar2(100 byte),
    request_xml_data            clob,
    response_xml_data           clob,
    response_json_data          clob,
    entity_id                   number,
    entity_type                 varchar2(100 byte),
    enroll_renewal_batch_number number,
    created_by                  varchar2(100 byte),
    website_api_request_id      number
);

