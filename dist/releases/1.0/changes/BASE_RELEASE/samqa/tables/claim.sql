-- liquibase formatted sql
-- changeset SAMQA:1754374153064 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\claim.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/claim.sql:null:48d71d54a486ee67d8dd9750a853743ca753f10a:create

create table samqa.claim (
    claim_id         number(9, 0) not null enable,
    pers_id          number(9, 0) not null enable,
    prov_id          number(9, 0) not null enable,
    claim_date_start date not null enable,
    claim_date_end   date,
    claim_bill       number(15, 2),
    service_doctor   varchar2(100 byte),
    claim_paid       number(15, 2),
    remainder        number(15, 2),
    claim_code       varchar2(20 byte),
    send_date        date,
    receive_date     date,
    note             varchar2(4000 byte),
    pers_patient     number(9, 0) not null enable,
    bill_val         number(15, 2)
);

create unique index samqa.claim_pk on
    samqa.claim (
        claim_id
    );

alter table samqa.claim
    add constraint claim_pk
        primary key ( claim_id )
            using index samqa.claim_pk enable;

