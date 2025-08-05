-- liquibase formatted sql
-- changeset SAMQA:1754373932903 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\person_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/person_n5.sql:null:82540e3785166af5fc90afc11631fa7deae235e8:create

create index samqa.person_n5 on
    samqa.person ( replace(ssn, '-') );

