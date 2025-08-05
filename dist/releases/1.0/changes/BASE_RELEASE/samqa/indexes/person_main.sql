-- liquibase formatted sql
-- changeset SAMQA:1754373932861 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\person_main.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/person_main.sql:null:d3ad5838223f7047072de759d6b595e003672099:create

create index samqa.person_main on
    samqa.person (
        pers_main
    );

