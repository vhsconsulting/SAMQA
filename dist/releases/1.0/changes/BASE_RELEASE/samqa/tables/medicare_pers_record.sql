-- liquibase formatted sql
-- changeset SAMQA:1754374160530 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\medicare_pers_record.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/medicare_pers_record.sql:null:60739d130d68b6e7bfb78e2ff3378d0f24fd8eb3:create

create table samqa.medicare_pers_record (
    pers_id                number,
    hic_number             varchar2(30 byte),
    cms_doc_crl_number     varchar2(30 byte),
    effective_date         date,
    effective_end_date     date,
    creation_date          date,
    last_update_date       date,
    ssn                    varchar2(11 byte),
    acc_num                varchar2(30 byte),
    tin_result_code        varchar2(2 byte),
    msp_effective_date     varchar2(10 byte),
    msp_termination_date   varchar2(10 byte),
    medicare_reason        varchar2(100 byte),
    medicare_eff_date      varchar2(100 byte),
    medicare_term_date     varchar2(100 byte),
    medicare_a_eff_date    varchar2(100 byte),
    medicare_a_term_date   varchar2(100 byte),
    medicare_b_eff_date    varchar2(100 byte),
    medicare_b_term_date   varchar2(100 byte),
    date_of_death          varchar2(100 byte),
    medicare_c_eff_date    varchar2(100 byte),
    medicare_c_term_date   varchar2(100 byte),
    medicare_d_eff_date    varchar2(100 byte),
    medicare_d_term_date   varchar2(100 byte),
    medicare_d_elig_s_date varchar2(100 byte),
    medicare_d_elig_t_date varchar2(100 byte),
    entrp_id               number,
    ein                    varchar2(30 byte)
);

