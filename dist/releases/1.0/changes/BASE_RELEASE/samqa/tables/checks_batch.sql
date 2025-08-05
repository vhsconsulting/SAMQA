-- liquibase formatted sql
-- changeset SAMQA:1754374153037 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\checks_batch.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/checks_batch.sql:null:f04fdfc358872f3fcc9f13be1f8880638d4b2c8c:create

create table samqa.checks_batch (
    check_batch_id      number,
    employer_payment_id number,
    cobra_payment_id    number,
    check_number        number,
    creation_date       date default sysdate,
    created_by          number,
    last_update_date    date default sysdate,
    last_updated_by     number,
    entrp_id            number,
    acc_id              number
);

alter table samqa.checks_batch add primary key ( check_batch_id )
    using index enable;

