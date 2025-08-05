-- liquibase formatted sql
-- changeset SAMQA:1754373930725 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\deductible_balance_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/deductible_balance_n2.sql:null:f784acd151524fdb053489ff7582223f3663951b:create

create index samqa.deductible_balance_n2 on
    samqa.deductible_balance (
        pers_id
    );

