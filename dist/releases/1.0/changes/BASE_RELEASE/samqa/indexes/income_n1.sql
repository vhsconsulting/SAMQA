-- liquibase formatted sql
-- changeset SAMQA:1754373931665 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\income_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/income_n1.sql:null:62070a765cb882b0c03b188ef3f13222bdf96378:create

create index samqa.income_n1 on
    samqa.income (
        contributor,
        cc_number
    );

