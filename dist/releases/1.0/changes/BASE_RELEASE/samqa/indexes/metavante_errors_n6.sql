-- liquibase formatted sql
-- changeset SAMQA:1754373932187 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_errors_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_errors_n6.sql:null:8e034aa07db72da5febe2039c2b58195fc81a3ec:create

create index samqa.metavante_errors_n6 on
    samqa.metavante_errors (
        record_id
    );

