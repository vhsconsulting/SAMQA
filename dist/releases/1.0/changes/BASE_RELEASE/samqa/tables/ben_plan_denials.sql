-- liquibase formatted sql
-- changeset SAMQA:1754374152128 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ben_plan_denials.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ben_plan_denials.sql:null:6c59d4063932a77abd1d1495f9e87997ecebc204:create

create table samqa.ben_plan_denials (
    ben_plan_id       number,
    acc_id            number,
    lookup_code       varchar2(20 byte),
    accept_flag       varchar2(1 byte),
    deny_reason       varchar2(500 byte),
    creation_date     date default sysdate,
    created_by        number,
    last_updated_by   number,
    last_updated_date date default sysdate,
    start_date        date,
    end_date          date
);

