-- liquibase formatted sql
-- changeset SAMQA:1754374154695 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\deductible_balance.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/deductible_balance.sql:null:c336bbeb6c0ae7bb566029de2a19d360b544d824:create

create table samqa.deductible_balance (
    balance_id        number,
    acc_id            number,
    pers_id           number,
    claim_id          number,
    deductible_amount number,
    pay_date          date,
    status            varchar2(255 byte),
    note              varchar2(50 byte),
    creation_date     date default sysdate,
    created_by        number,
    last_updated_date date default sysdate,
    last_updated_by   number,
    pers_patient      number
);

alter table samqa.deductible_balance add primary key ( balance_id )
    using index enable;

