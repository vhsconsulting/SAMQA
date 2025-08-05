-- liquibase formatted sql
-- changeset SAMQA:1754374158494 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\feedback.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/feedback.sql:null:3611b955eba2dc3141d28e085f2fff9a232b88ca:create

create table samqa.feedback (
    tax_id               varchar2(255 byte) not null enable,
    product_satisfaction number,
    service_satisfaction number,
    team_satisfaction    number,
    improvement_comment  varchar2(2000 byte),
    email                varchar2(50 byte),
    phone                varchar2(20 byte),
    submission_date      date,
    entity_id            varchar2(20 char),
    entity_type          varchar2(10 char),
    skipped              varchar2(3 byte)
);

alter table samqa.feedback add check ( product_satisfaction between 1 and 5 ) enable;

alter table samqa.feedback add check ( service_satisfaction between 1 and 5 ) enable;

alter table samqa.feedback add check ( team_satisfaction between 1 and 5 ) enable;

