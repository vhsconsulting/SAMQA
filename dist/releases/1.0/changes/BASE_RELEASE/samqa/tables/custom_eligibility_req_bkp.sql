-- liquibase formatted sql
-- changeset SAMQA:1754374154355 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\custom_eligibility_req_bkp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/custom_eligibility_req_bkp.sql:null:2c3428fca7799fdb17091919e410735bc82a0a7e:create

create table samqa.custom_eligibility_req_bkp (
    eligibility_id          number,
    entity_id               number,
    no_of_hrs_part_time     varchar2(100 byte),
    no_of_hrs_seasonal      varchar2(100 byte),
    no_of_hrs_current       varchar2(100 byte),
    new_ee_month_servc      varchar2(100 byte),
    collective_bargain_flag varchar2(10 byte),
    union_ee_join_flag      varchar2(10 byte),
    plan_new_ee_join        varchar2(100 byte),
    select_entry_date_flag  varchar2(10 byte),
    min_age_req             varchar2(100 byte),
    automatic_enroll        varchar2(10 byte),
    revoke_elect_flag       varchar2(10 byte),
    cease_covg_flag         varchar2(10 byte),
    contrib_flag            varchar2(100 byte),
    contrib_amt             varchar2(20 byte),
    percent_contrib         varchar2(10 byte),
    permit_cash_flag        varchar2(10 byte),
    limit_cash_flag         varchar2(10 byte),
    salesrep_flag           varchar2(2 byte),
    ga_flag                 varchar2(2 byte),
    salesrep_id             varchar2(100 byte),
    ga_id                   varchar2(100 byte),
    source                  varchar2(100 byte),
    created_by              number,
    creation_date           date,
    last_updated_by         number,
    last_update_date        date,
    acct_for_pretax_flag    varchar2(2 byte),
    permit_partcp_eoy       varchar2(2 byte),
    ee_exclude_plan_flag    varchar2(2 byte),
    coincident_next_flag    varchar2(2 byte),
    limit_cash_paid         number
);

