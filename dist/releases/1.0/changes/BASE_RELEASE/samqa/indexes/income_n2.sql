-- liquibase formatted sql
-- changeset SAMQA:1754373931686 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\income_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/income_n2.sql:null:ce7fdf55194c1309ffcd4ee202ad4ad390cc22b7:create

create index samqa.income_n2 on
    samqa.income (
        fee_code,
        fee_date
    );

