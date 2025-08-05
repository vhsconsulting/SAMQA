-- liquibase formatted sql
-- changeset SAMQA:1754374154718 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\deductible_rule.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/deductible_rule.sql:null:81388bd76a961def44c70c8b6438d5acf576e039:create

create table samqa.deductible_rule (
    rule_id           number,
    name              varchar2(50 byte),
    ben_plan_id       number,
    entrp_id          number,
    acc_id            number,
    rule_type         varchar2(25 byte),
    status            varchar2(10 byte),
    note              varchar2(3200 byte),
    creation_date     date default sysdate,
    created_by        number,
    last_updated_date date default sysdate,
    last_updated_by   number
);

alter table samqa.deductible_rule add primary key ( rule_id )
    using index enable;

