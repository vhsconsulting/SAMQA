-- liquibase formatted sql
-- changeset SAMQA:1754373932221 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_settlements_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_settlements_n1.sql:null:6ce433a6ef0f02f2c20c7270b46ce2965d42a2a1:create

create index samqa.metavante_settlements_n1 on
    samqa.metavante_settlements ( to_char(settlement_number)
                                  || transaction_date );

