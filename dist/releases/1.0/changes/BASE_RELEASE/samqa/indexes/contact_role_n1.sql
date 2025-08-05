-- liquibase formatted sql
-- changeset SAMQA:1754373930636 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\contact_role_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/contact_role_n1.sql:null:06da049c66de96864f935e3dd3977bb17dd7b819:create

create index samqa.contact_role_n1 on
    samqa.contact_role (
        contact_id
    );

