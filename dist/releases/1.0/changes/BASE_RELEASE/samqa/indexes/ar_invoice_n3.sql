-- liquibase formatted sql
-- changeset SAMQA:1754373929131 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_invoice_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_invoice_n3.sql:null:ad59e53df37340b6b15e31c7fc9673fdcdf8b12e:create

create index samqa.ar_invoice_n3 on
    samqa.ar_invoice (
        rate_plan_id
    );

