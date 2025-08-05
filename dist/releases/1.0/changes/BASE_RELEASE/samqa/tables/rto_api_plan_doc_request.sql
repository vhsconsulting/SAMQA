-- liquibase formatted sql
-- changeset SAMQA:1754374162646 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\rto_api_plan_doc_request.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/rto_api_plan_doc_request.sql:null:f27424ddddf5444202f8dc483dfdf6fd71ada6b5:create

create table samqa.rto_api_plan_doc_request (
    api_request_id        number,
    acc_id                number,
    verified_renewal_date date,
    batch_number          number,
    source                varchar2(50 byte),
    api_posted_data       clob,
    creation_date         date,
    last_update_date      date,
    process_status        varchar2(1 byte),
    return_status         varchar2(1 byte),
    return_error_message  varchar2(4000 byte),
    entrp_id              number,
    created_by            number,
    last_updated_by       number,
    ben_plan_id           number
);

