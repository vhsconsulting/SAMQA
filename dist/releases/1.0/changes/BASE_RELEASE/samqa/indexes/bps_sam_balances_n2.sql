-- liquibase formatted sql
-- changeset SAMQA:1754373929774 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\bps_sam_balances_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/bps_sam_balances_n2.sql:null:be258902500466595b0b0955c02bbd1a4bcf8702:create

create index samqa.bps_sam_balances_n2 on
    samqa.bps_sam_balances (
        sam_bal
    );

