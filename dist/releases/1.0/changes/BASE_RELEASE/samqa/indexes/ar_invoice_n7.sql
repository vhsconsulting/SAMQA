-- liquibase formatted sql
-- changeset SAMQA:1754373929178 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_invoice_n7.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_invoice_n7.sql:null:51479e5885f0389d88a5f476904233ee3909e923:create

create index samqa.ar_invoice_n7 on
    samqa.ar_invoice (
        status
    );

