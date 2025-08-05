-- liquibase formatted sql
-- changeset SAMQA:1754374159831 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\irs_amendments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/irs_amendments.sql:null:837356aa503ac6d4e636acdabb853e5bdb2fd4fc:create

create table samqa.irs_amendments (
    amendment_id      number,
    amendment         varchar2(4000 byte),
    start_date        date,
    end_date          date,
    created_by        number,
    creation_date     date,
    last_updated_by   number,
    last_updated_date date,
    plan_type         varchar2(10 byte),
    rollover          varchar2(1 byte),
    transaction_limit number,
    annual_election   number,
    no_grace          varchar2(10 byte)
);

