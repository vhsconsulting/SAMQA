-- liquibase formatted sql
-- changeset SAMQA:1754374163199 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\send_invoice.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/send_invoice.sql:null:8f9e04550122a3654c4f13c82613c042629325e7:create

create table samqa.send_invoice (
    entrp_id      number,
    email         varchar2(1000 byte),
    flag          varchar2(1 byte),
    created_by    number,
    creation_date date default sysdate,
    ben_plan_id   number
);

