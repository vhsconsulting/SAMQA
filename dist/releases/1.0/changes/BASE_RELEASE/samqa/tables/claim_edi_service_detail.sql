-- liquibase formatted sql
-- changeset SAMQA:1754374153267 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\claim_edi_service_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/claim_edi_service_detail.sql:null:1307815d711bed57eed8cb621ec03fe881a2c723:create

create table samqa.claim_edi_service_detail (
    claim_service_detail_id number not null enable,
    claim_detail_id         number not null enable,
    service_provider_name   varchar2(255 byte),
    service_provider_id     varchar2(35 byte),
    patient_name            varchar2(255 byte),
    service_procedure_code  varchar2(100 byte),
    service_monetary_amount varchar2(30 byte),
    service_start_date      varchar2(8 byte),
    service_end_date        varchar2(8 byte),
    batch_number            varchar2(50 byte),
    status_cd               varchar2(10 byte)
);

create unique index samqa.claim_edi_service_detail_pk01 on
    samqa.claim_edi_service_detail (
        claim_service_detail_id
    );

alter table samqa.claim_edi_service_detail
    add constraint claim_edi_service_detail_pk01
        primary key ( claim_service_detail_id )
            using index samqa.claim_edi_service_detail_pk01 enable;

