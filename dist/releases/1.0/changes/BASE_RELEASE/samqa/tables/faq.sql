-- liquibase formatted sql
-- changeset SAMQA:1754374158353 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\faq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/faq.sql:null:0034fb444004d3f38d8668b11056e37fe55f91d5:create

create table samqa.faq (
    faq_id     number,
    section    number,
    faq_number number,
    question   varchar2(255 byte),
    answer     varchar2(3200 byte),
    visible    varchar2(1 byte),
    source     varchar2(30 byte)
);

