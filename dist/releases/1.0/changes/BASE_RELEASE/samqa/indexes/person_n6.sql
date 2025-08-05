-- liquibase formatted sql
-- changeset SAMQA:1754373932911 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\person_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/person_n6.sql:null:dac8c7941934816adef18228d481d01cff45ce52:create

create index samqa.person_n6 on
    samqa.person (
        entrp_id
    );

