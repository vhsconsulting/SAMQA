-- liquibase formatted sql
-- changeset SAMQA:1754373929774 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\bps_sam_balances_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/bps_sam_balances_n3.sql:null:67e5719967bbbc03f97a1ec63019d21c3c3a332a:create

create index samqa.bps_sam_balances_n3 on
    samqa.bps_sam_balances (
        bal_dff
    );

