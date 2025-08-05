-- liquibase formatted sql
-- changeset SAMQA:1754373929066 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_invoice_dist_plans_n7.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_invoice_dist_plans_n7.sql:null:a7b331947c566eebd9fd6345b7fdfa49eb934f00:create

create index samqa.ar_invoice_dist_plans_n7 on
    samqa.ar_invoice_dist_plans (
        product_type
    );

