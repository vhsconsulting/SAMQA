-- liquibase formatted sql
-- changeset SAMQA:1754373931635 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\income_f3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/income_f3.sql:null:bea3dee823e679bb44ee63134fc7cee5cb1c77a9:create

create index samqa.income_f3 on
    samqa.income ( trunc(due_date, 'fmmm') );

