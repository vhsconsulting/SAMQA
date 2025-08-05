-- liquibase formatted sql
-- changeset SAMQA:1754373932237 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_settlements_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_settlements_n3.sql:null:3e9beabc93c899c07ddeca83e2cb9f5deaf0415c:create

create index samqa.metavante_settlements_n3 on
    samqa.metavante_settlements ( trunc(creation_date) );

