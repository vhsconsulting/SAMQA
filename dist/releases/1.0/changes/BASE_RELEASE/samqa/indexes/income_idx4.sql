-- liquibase formatted sql
-- changeset SAMQA:1754373931654 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\income_idx4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/income_idx4.sql:null:1fc2a252ced782c1ff7a7f4843a39927d47e8903:create

create index samqa.income_idx4 on
    samqa.income (
        contributor
    );

