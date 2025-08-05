-- liquibase formatted sql
-- changeset SAMQA:1754374163847 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\u_security.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/u_security.sql:null:44691ad909f70e25953fd5b3beec4c884ad7a5d1:create

create table samqa.u_security (
    name varchar2(3200 byte)
);

