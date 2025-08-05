-- liquibase formatted sql
-- changeset SAMQA:1754374160688 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\metavante_error_codes.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/metavante_error_codes.sql:null:ae526f689ae4b1268d3798a292be54460d810a68:create

create table samqa.metavante_error_codes (
    error_id          number,
    error_description varchar2(3200 byte),
    creation_date     date default sysdate,
    last_update_date  date default sysdate
);

