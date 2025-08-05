-- liquibase formatted sql
-- changeset SAMQA:1754373931696 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\income_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/income_n5.sql:null:b634757ddb19d0dd6f48ad4db1a317444ac926c5:create

create index samqa.income_n5 on
    samqa.income (
        fee_code
    );

