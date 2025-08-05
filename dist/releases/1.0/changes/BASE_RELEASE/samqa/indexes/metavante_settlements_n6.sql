-- liquibase formatted sql
-- changeset SAMQA:1754373932261 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_settlements_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_settlements_n6.sql:null:5e665cf06215cfe8a25c4e0b4fe304b00fb6a300:create

create index samqa.metavante_settlements_n6 on
    samqa.metavante_settlements ( trunc(to_date(
        settlement_date, 'YYYYMMDD')) );

