-- liquibase formatted sql
-- changeset SAMQA:1754373929058 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_invoice_dist_plans_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_invoice_dist_plans_n3.sql:null:ed95ec916cad685a9343547336e1ddde715a61e2:create

create index samqa.ar_invoice_dist_plans_n3 on
    samqa.ar_invoice_dist_plans (
        invoice_id,
        entrp_id
    );

