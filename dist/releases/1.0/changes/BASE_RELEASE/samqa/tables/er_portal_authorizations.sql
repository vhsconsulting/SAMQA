-- liquibase formatted sql
-- changeset SAMQA:1754374157814 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\er_portal_authorizations.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/er_portal_authorizations.sql:null:56386a451ef3cdc06975a1590926ee98eb00de38:create

create table samqa.er_portal_authorizations (
    authorize_req_id number,
    broker_id        number,
    acc_id           number,
    user_id          number,
    request_status   varchar2(50 byte),
    creation_date    date,
    created_by       number,
    last_update_date date,
    last_updated_by  number
);

