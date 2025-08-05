-- liquibase formatted sql
-- changeset SAMQA:1754373930024 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\checks_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/checks_n1.sql:null:1142728a247603e2e2d318eefcd26a26b71ad12f:create

create index samqa.checks_n1 on
    samqa.checks (
        check_number
    );

