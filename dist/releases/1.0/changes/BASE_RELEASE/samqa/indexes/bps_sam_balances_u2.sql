-- liquibase formatted sql
-- changeset SAMQA:1754373929787 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\bps_sam_balances_u2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/bps_sam_balances_u2.sql:null:4671aae05245d848dd3b871e011def36d07aac4a:create

create index samqa.bps_sam_balances_u2 on
    samqa.bps_sam_balances (
        acc_id
    );

