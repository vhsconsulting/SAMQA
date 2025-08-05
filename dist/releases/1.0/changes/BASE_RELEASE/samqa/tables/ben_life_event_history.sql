-- liquibase formatted sql
-- changeset SAMQA:1754374152071 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ben_life_event_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ben_life_event_history.sql:null:ea5985983febdc6f7742fe85bb5f416718a6ce50:create

create table samqa.ben_life_event_history (
    life_event_id            number,
    acc_num                  varchar2(30 byte),
    acc_id                   number,
    pers_id                  number,
    entrp_id                 number,
    ben_plan_id              number,
    life_event_code          varchar2(30 byte),
    description              varchar2(2000 byte),
    annual_election          number,
    effective_date           date,
    status                   varchar2(255 byte),
    payroll_contribution     varchar2(255 byte),
    batch_number             varchar2(30 byte),
    processed_status         varchar2(255 byte),
    error_message            varchar2(255 byte),
    creation_date            date,
    created_by               number,
    last_update_date         date,
    last_updated_by          number,
    cov_tier_name            varchar2(255 byte),
    processed_date           date,
    process_batch_num        number,
    original_annual_election number
);

