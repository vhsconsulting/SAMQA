-- liquibase formatted sql
-- changeset SAMQA:1754373930620 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\contact_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/contact_n3.sql:null:5b7a710501568be6c2781665b3a13b2f38c56066:create

create index samqa.contact_n3 on
    samqa.contact (
        entity_type
    );

