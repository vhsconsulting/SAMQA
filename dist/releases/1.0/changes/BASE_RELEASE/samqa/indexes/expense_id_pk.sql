-- liquibase formatted sql
-- changeset SAMQA:1754373931454 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\expense_id_pk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/expense_id_pk.sql:null:70954cf555f07603959933052a83999db6f6f137:create

create unique index samqa.expense_id_pk on
    samqa.plan_eligibile_expenses (
        expense_id
    );

