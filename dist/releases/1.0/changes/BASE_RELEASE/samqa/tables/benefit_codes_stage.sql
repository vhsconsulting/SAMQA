-- liquibase formatted sql
-- changeset SAMQA:1754374152450 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\benefit_codes_stage.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/benefit_codes_stage.sql:null:63fb9e2cfd4cf73aec6e86405c42d46aa5b590e3:create

create table samqa.benefit_codes_stage (
    seq_id                   number,
    entity_id                number,
    benefit_code_id          varchar2(100 byte),
    benefit_code_name        varchar2(1000 byte),
    status                   varchar2(2 byte),
    batch_number             number,
    creation_date            date,
    created_by               number,
    last_updated_by          number,
    description              varchar2(2000 byte),
    entity_type              varchar2(100 byte),
    flg_block                varchar2(1 byte),
    eligibility              varchar2(1000 byte),
    er_cont_pref             varchar2(300 byte),
    ee_cont_pref             varchar2(300 byte),
    er_ee_contrib_lng        varchar2(1000 byte),
    refer_to_doc             varchar2(100 byte),
    entrp_id                 number(10, 0),
    eligibility_refer_to_doc varchar2(100 byte),
    fully_insured_flag       varchar2(1 byte) default 'N',
    self_insured_flag        varchar2(1 byte) default 'N',
    voluntary_life_add_info  varchar2(4000 byte)
);

