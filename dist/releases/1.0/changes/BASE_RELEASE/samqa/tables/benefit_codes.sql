-- liquibase formatted sql
-- changeset SAMQA:1754374152422 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\benefit_codes.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/benefit_codes.sql:null:370647e1b6d354b2995627f6c41ee05be10618b2:create

create table samqa.benefit_codes (
    benefit_code_id          number,
    benefit_code_name        varchar2(200 byte),
    entity_id                number,
    entity_type              varchar2(100 byte),
    description              varchar2(1000 byte),
    eligibility              varchar2(1000 byte),
    coverage_tier            varchar2(100 byte),
    er_cont_pref             varchar2(300 byte),
    ee_cont_pref             varchar2(300 byte),
    creation_date            date,
    created_by               number,
    last_update_date         date,
    last_updated_by          number,
    er_ee_contrib_lng        varchar2(1000 byte),
    refer_to_doc             varchar2(1000 byte),
    eligibility_refer_to_doc varchar2(100 byte),
    fully_insured_flag       varchar2(1 byte) default 'N',
    self_insured_flag        varchar2(1 byte) default 'N',
    voluntary_life_add_info  varchar2(4000 byte),
    eligibility_code         varchar2(200 byte),
    er_ee_contrib_lng_code   varchar2(200 byte),
    flg_block                varchar2(2 byte)
);

alter table samqa.benefit_codes add primary key ( benefit_code_id )
    using index enable;

