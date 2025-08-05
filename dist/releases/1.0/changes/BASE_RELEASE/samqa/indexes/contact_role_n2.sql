-- liquibase formatted sql
-- changeset SAMQA:1754373930644 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\contact_role_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/contact_role_n2.sql:null:73ada92a967930fc1fe6d16e80594e7518907e32:create

create index samqa.contact_role_n2 on
    samqa.contact_role (
        role_type
    );

