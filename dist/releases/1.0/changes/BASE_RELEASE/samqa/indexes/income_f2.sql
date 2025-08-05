-- liquibase formatted sql
-- changeset SAMQA:1754373931624 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\income_f2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/income_f2.sql:null:839ef40e61a1db9909f0c21e445c3e6757f0d696:create

create index samqa.income_f2 on
    samqa.income ( trunc(fee_date) );

