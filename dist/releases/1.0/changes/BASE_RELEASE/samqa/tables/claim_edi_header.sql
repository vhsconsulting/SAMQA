-- liquibase formatted sql
-- changeset SAMQA:1754374153237 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\claim_edi_header.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/claim_edi_header.sql:null:ec2f80049abfbc969ac365405ffec723e032916c:create

create table samqa.claim_edi_header (
    claim_header_id           number not null enable,
    trans_set_cntrl_num       varchar2(9 byte),
    hrrchcl_struct_code       varchar2(4 byte),
    trans_set_prps_code       varchar2(2 byte),
    trans_ref_id              varchar2(30 byte),
    trans_create_dt           varchar2(8 byte),
    trans_create_time         varchar2(8 byte),
    trans_type_code           varchar2(2 byte),
    ref_id_qlfr               varchar2(2 byte),
    ref_id                    varchar2(12 byte),
    submitter_idntfr_code     varchar2(2 byte),
    submitter_type_qlfr       varchar2(1 byte),
    submitter_last_name       varchar2(35 byte),
    submitter_first_name      varchar2(25 byte),
    submitter_middl_name      varchar2(25 byte),
    sumbitter_code_qlfr       varchar2(2 byte),
    submitter_prim_id_num     varchar2(80 byte),
    submitter_cont_func_code  varchar2(2 byte),
    submitter_cont_name       varchar2(60 byte),
    comm_num_qlfr             varchar2(2 byte),
    comm_num                  varchar2(80 byte),
    comm_num_qlfr_situational varchar2(2 byte),
    comm_num_situational      varchar2(80 byte),
    rcvr_entty_id_cd          varchar2(3 byte),
    rcvr_entty_type_qlfr      varchar2(1 byte),
    rcvr_nm                   varchar2(35 byte),
    rcvr_cd_qlfr              varchar2(2 byte),
    rcvr_id_cd                varchar2(80 byte),
    status_code               varchar2(10 byte),
    batch_number              varchar2(50 byte),
    creation_date             date,
    last_updated_date         date
);

create unique index samqa.claim_edi_header_pk01 on
    samqa.claim_edi_header (
        claim_header_id
    );

alter table samqa.claim_edi_header
    add constraint claim_edi_header_pk01
        primary key ( claim_header_id )
            using index samqa.claim_edi_header_pk01 enable;

