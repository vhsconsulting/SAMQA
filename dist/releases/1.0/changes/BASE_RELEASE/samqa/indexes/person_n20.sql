-- liquibase formatted sql
-- changeset SAMQA:1754373932894 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\person_n20.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/person_n20.sql:null:627a9f21c2374a3f759ae5ba9b7ec4d59883d086:create

create index samqa.person_n20 on
    samqa.person (
        email
    );

