-- liquibase formatted sql
-- changeset SAMQA:1754373931827 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\invoice_dist_summary_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/invoice_dist_summary_n3.sql:null:029906cba807188a76e8b87b399a7c98266a9aa9:create

create index samqa.invoice_dist_summary_n3 on
    samqa.invoice_distribution_summary (
        rate_code,
        account_type
    );

