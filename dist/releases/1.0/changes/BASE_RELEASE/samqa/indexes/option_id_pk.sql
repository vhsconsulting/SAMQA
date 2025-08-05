-- liquibase formatted sql
-- changeset SAMQA:1754373932568 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\option_id_pk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/option_id_pk.sql:null:bf5e44f930c34ce926776f93fe0d1a11e2df852b:create

create unique index samqa.option_id_pk on
    samqa.hra_deductible_options (
        option_id
    );

