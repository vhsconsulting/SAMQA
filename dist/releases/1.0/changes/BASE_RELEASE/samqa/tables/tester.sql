-- liquibase formatted sql
-- changeset SAMQA:1754374163756 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\tester.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/tester.sql:null:7cbe33c5fcebd18914919fd8853c3698cfec771f:create

create table samqa.tester (
    name varchar2(1000 byte)
);

