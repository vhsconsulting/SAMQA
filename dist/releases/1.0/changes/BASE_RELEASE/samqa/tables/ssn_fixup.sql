-- liquibase formatted sql
-- changeset SAMQA:1754374163375 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ssn_fixup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ssn_fixup.sql:null:5ece1423b743865a67c10497fe49b7edcf8b615a:create

create table samqa.ssn_fixup (
    ssn varchar2(20 byte)
);

