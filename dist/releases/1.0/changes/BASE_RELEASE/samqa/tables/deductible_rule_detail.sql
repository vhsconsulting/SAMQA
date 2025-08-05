-- liquibase formatted sql
-- changeset SAMQA:1754374154744 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\deductible_rule_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/deductible_rule_detail.sql:null:ea702d96e62ed1565a90bfb79d50fbc946765e9b:create

create table samqa.deductible_rule_detail (
    rule_detail_id     number,
    rule_id            number,
    rank               number,
    entity             varchar2(15 byte),
    type_of_deductible varchar2(15 byte),
    max_deductible     number,
    status             varchar2(10 byte),
    note               varchar2(3200 byte),
    creation_date      date default sysdate,
    created_by         number,
    last_updated_date  date default sysdate,
    last_updated_by    number,
    min_deductible     number,
    maximum_cap        number
);

alter table samqa.deductible_rule_detail add primary key ( rule_detail_id )
    using index enable;

