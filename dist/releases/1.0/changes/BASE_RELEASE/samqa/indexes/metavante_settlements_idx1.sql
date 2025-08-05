-- liquibase formatted sql
-- changeset SAMQA:1754373932213 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_settlements_idx1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_settlements_idx1.sql:null:ef6d3f1875b578ed9344431a493648a69611315f:create

create unique index samqa.metavante_settlements_idx1 on
    samqa.metavante_settlements (
        settlement_number,
        transaction_date,
        acc_num
    );

