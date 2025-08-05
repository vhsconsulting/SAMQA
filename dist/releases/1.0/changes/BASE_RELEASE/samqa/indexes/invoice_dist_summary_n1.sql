-- liquibase formatted sql
-- changeset SAMQA:1754373931810 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\invoice_dist_summary_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/invoice_dist_summary_n1.sql:null:0284a1bffaa18f2cd2636cbbe37acb7d5d1e0f9c:create

create index samqa.invoice_dist_summary_n1 on
    samqa.invoice_distribution_summary (
        invoice_id
    );

