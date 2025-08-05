-- liquibase formatted sql
-- changeset SAMQA:1754373929311 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\balance_register_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/balance_register_n1.sql:null:8dd032eeafdcad52f2083ee4e0bffa054ef9597b:create

create index samqa.balance_register_n1 on
    samqa.balance_register (
        acc_id
    );

