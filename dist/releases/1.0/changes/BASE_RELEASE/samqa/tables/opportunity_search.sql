-- liquibase formatted sql
-- changeset SAMQA:1754374161758 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\opportunity_search.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/opportunity_search.sql:null:ca1b0c508ef77f266e05a9614890e18edaa36658:create

create table samqa.opportunity_search (
    sam_user_id       number not null enable,
    employer_name     varchar2(255 byte),
    acc_num           varchar2(255 byte),
    account_type      varchar2(255 byte),
    assigned_dept     varchar2(255 byte),
    assigned_person   varchar2(255 byte),
    opportunity_type  varchar2(20 byte),
    imp_stage_cde     varchar2(50 byte),
    plan_start_year   varchar2(50 byte),
    creation_date     date,
    created_by        number,
    last_updated_date date,
    last_updated_by   number
);

