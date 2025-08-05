-- liquibase formatted sql
-- changeset SAMQA:1754373929040 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_invoice_dist_plans_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_invoice_dist_plans_n1.sql:null:a17a21d7e850a7d0251c3209ca53f6b57d55fcf6:create

create index samqa.ar_invoice_dist_plans_n1 on
    samqa.ar_invoice_dist_plans (
        invoice_id
    );

