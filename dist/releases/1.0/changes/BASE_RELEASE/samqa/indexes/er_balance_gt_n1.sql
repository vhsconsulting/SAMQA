-- liquibase formatted sql
-- changeset SAMQA:1754373931421 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\er_balance_gt_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/er_balance_gt_n1.sql:null:d37fad892816f7f060056be9b0cfed025bb65d77:create

create index samqa.er_balance_gt_n1 on
    samqa.er_balance_gt (
        entrp_id
    );

