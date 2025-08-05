-- liquibase formatted sql
-- changeset SAMQA:1754373930537 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\contact_import_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/contact_import_n1.sql:null:f3583f24f35a3f317869f3a3eeddbd52bbbbaea2:create

create index samqa.contact_import_n1 on
    samqa.contact_import (
        name
    );

