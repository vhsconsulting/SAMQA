-- liquibase formatted sql
-- changeset SAMQA:1754374161566 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\online_renewals.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/online_renewals.sql:null:c0e4668a68c0cd3e191b64ada94d167862a7e531:create

create table samqa.online_renewals (
    renewal_id           number,
    entrp_id             number,
    acc_id               number,
    ben_plan_id          number,
    entity_type          varchar2(100 byte),
    grandfathered        varchar2(100 byte),
    clm_lang_in_spd      varchar2(100 byte),
    ben_plan_number      number,
    no_of_eligible       number,
    no_of_employees      number,
    affiliated_er        varchar2(1 byte),
    controlled_group     varchar2(1 byte),
    updated              varchar2(1 byte),
    note                 varchar2(4000 byte),
    bank_acct_num        varchar2(20 byte),
    plan_include         varchar2(500 byte),
    form55_opted         varchar2(1 byte),
    creation_date        date default sysdate,
    created_by           number,
    no_of_eligible_old   number,
    affiliated_er_old    varchar2(1 byte),
    controlled_group_old varchar2(1 byte),
    plan_include_old     varchar2(500 byte),
    old_entity_type      varchar2(30 byte),
    source               varchar2(50 byte),
    erissa_erap_doc_type varchar2(1 byte),
    fiscal_end_date      date
);

alter table samqa.online_renewals add primary key ( renewal_id )
    using index enable;

