-- liquibase formatted sql
-- changeset SAMQA:1754373931818 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\invoice_dist_summary_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/invoice_dist_summary_n2.sql:null:fbbe13c1cd370cc6346eba1fc8f92a44d6820f5c:create

create index samqa.invoice_dist_summary_n2 on
    samqa.invoice_distribution_summary (
        entrp_id,
        pers_id
    );

