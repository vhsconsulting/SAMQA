-- liquibase formatted sql
-- changeset SAMQA:1754373932143 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_errors_n10.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_errors_n10.sql:null:e37ecc18a97d13337ec9a1245a34fbbd16e25372:create

create index samqa.metavante_errors_n10 on
    samqa.metavante_errors ( trunc(creation_date) );

