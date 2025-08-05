-- liquibase formatted sql
-- changeset SAMQA:1754373930734 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\deductible_balance_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/deductible_balance_n3.sql:null:4d7a0dd11fd42e6429f886d1d47f97d29f066110:create

create index samqa.deductible_balance_n3 on
    samqa.deductible_balance (
        claim_id
    );

