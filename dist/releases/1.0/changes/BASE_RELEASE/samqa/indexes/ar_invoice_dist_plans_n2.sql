-- liquibase formatted sql
-- changeset SAMQA:1754373929049 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_invoice_dist_plans_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_invoice_dist_plans_n2.sql:null:d9e509dddf9fc4d0fefede9c01cd61a6ad2dc654:create

create index samqa.ar_invoice_dist_plans_n2 on
    samqa.ar_invoice_dist_plans (
        invoice_id,
        acc_id
    );

