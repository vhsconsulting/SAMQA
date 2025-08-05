-- liquibase formatted sql
-- changeset SAMQA:1754373930604 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\contact_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/contact_n1.sql:null:782b5bcae0a942ac4e315d6c650e9b4a5788604d:create

create index samqa.contact_n1 on
    samqa.contact (
        entity_id
    );

