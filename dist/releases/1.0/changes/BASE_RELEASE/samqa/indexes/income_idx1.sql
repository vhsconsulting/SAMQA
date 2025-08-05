-- liquibase formatted sql
-- changeset SAMQA:1754373931646 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\income_idx1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/income_idx1.sql:null:0b2e8e31d784ea575ea8c61d031f7ab5df38917f:create

create index samqa.income_idx1 on
    samqa.income (
        cc_number,
        contributor,
        fee_date
    );

