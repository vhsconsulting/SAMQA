-- liquibase formatted sql
-- changeset SAMQA:1754373929758 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\bps_sam_balances_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/bps_sam_balances_n1.sql:null:3989e48065474943e85d3eea4dc45c40f47251fc:create

create index samqa.bps_sam_balances_n1 on
    samqa.bps_sam_balances (
        account_status
    );

