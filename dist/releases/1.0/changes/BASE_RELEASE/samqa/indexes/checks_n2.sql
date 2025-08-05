-- liquibase formatted sql
-- changeset SAMQA:1754373930034 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\checks_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/checks_n2.sql:null:0b121a01b6454ded54cb9ae38cbad00add61d66a:create

create index samqa.checks_n2 on
    samqa.checks (
        acc_id
    );

