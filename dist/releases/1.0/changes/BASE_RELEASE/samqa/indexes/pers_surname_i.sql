-- liquibase formatted sql
-- changeset SAMQA:1754373932845 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\pers_surname_i.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/pers_surname_i.sql:null:6730a0555ab67b9ba5632876efe3ed0b5a31bcc0:create

create index samqa.pers_surname_i on
    samqa.person (
        last_name
    );

