-- liquibase formatted sql
-- changeset SAMQA:1754374151405 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\aid_term.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/aid_term.sql:null:47f84c8561dfa0e4e97227366d609d3fb18441a9:create

create table samqa.aid_term (
    acc_id  number(9, 0) not null enable,
    pers_id number(9, 0)
);

