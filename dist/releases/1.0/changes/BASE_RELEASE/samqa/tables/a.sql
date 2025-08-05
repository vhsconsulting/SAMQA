-- liquibase formatted sql
-- changeset SAMQA:1754374150700 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\a.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/a.sql:null:f1a66453b0a4118b2aeec468ebf67fdfdcb96d1f:create

create table samqa.a (
    c2      number,
    c3      number,
    s3      number,
    c4      number,
    s4      number,
    c5      number,
    c8      number,
    acc_num varchar2(30 byte)
);

