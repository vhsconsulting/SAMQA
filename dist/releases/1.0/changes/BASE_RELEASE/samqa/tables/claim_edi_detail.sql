-- liquibase formatted sql
-- changeset SAMQA:1754374153176 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\claim_edi_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/claim_edi_detail.sql:null:f7cf02a6550f71643dde2e81b71d939a940b42ea:create

create table samqa.claim_edi_detail (
    claim_detail_id         number not null enable,
    claim_header_id         number not null enable,
    bllng_prvdr_nm          varchar2(35 byte),
    bllng_prvdr_addrss1     varchar2(55 byte),
    bllng_prvdr_addrss2     varchar2(55 byte),
    bllng_prvdr_city        varchar2(30 byte),
    bllng_prvdr_stt_cd      varchar2(2 byte),
    bllng_prvdr_zip         varchar2(15 byte),
    bllng_prvdr_cntry_cd    varchar2(3 byte),
    bllng_prvdr_accnt_nmbr  varchar2(80 byte),
    bllng_prvdr_cntct_nm    varchar2(60 byte),
    bllng_prvdr_email       varchar2(80 byte),
    bllng_prvdr_phn         varchar2(80 byte),
    pay_to_prvdr_nm         varchar2(35 byte),
    pay_to_prvdr_addrss1    varchar2(55 byte),
    pay_to_prvdr_addrss2    varchar2(55 byte),
    pay_to_prvdr_city       varchar2(30 byte),
    pay_to_prvdr_stt_cd     varchar2(2 byte),
    pay_to_prvdr_zip        varchar2(15 byte),
    pay_to_prvdr_accnt_nmbr varchar2(80 byte),
    sbscrbr_nm              varchar2(35 byte),
    sbscrbr_addrss1         varchar2(55 byte),
    sbscrbr_addrss2         varchar2(55 byte),
    sbscrbr_city            varchar2(30 byte),
    sbscrbr_stt_cd          varchar2(2 byte),
    sbscrbr_zip             varchar2(15 byte),
    sbscrbr_nmbr            varchar2(80 byte),
    patient_last_nm         varchar2(35 byte),
    patient_frst_nm         varchar2(25 byte),
    patient_mddl_nm         varchar2(25 byte),
    claim_nmbr              varchar2(38 byte),
    service_amnt            varchar2(18 byte),
    patient_amnt_paid       varchar2(18 byte),
    bllng_note              varchar2(80 byte),
    patient_note            varchar2(80 byte),
    claim_note              varchar2(80 byte),
    eob_rqrd                varchar2(1 byte),
    rmbrsmnt_mthd           varchar2(10 byte),
    pers_id                 number(9, 0),
    acc_id                  number(9, 0),
    acc_num                 varchar2(20 byte),
    error_message           varchar2(100 byte),
    batch_number            varchar2(50 byte),
    status_cd               varchar2(10 byte)
);

create unique index samqa.claim_edi_detail_pk01 on
    samqa.claim_edi_detail (
        claim_detail_id
    );

alter table samqa.claim_edi_detail
    add constraint claim_edi_detail_pk01
        primary key ( claim_detail_id )
            using index samqa.claim_edi_detail_pk01 enable;

