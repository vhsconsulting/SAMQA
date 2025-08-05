-- liquibase formatted sql
-- changeset SAMQA:1754374158398 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\faqsection.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/faqsection.sql:null:d4ba206c520e6aa3aca92851cefa698bf68e5d47:create

create table samqa.faqsection (
    section_id   number,
    section_name varchar2(3200 byte),
    source       varchar2(30 byte)
);

