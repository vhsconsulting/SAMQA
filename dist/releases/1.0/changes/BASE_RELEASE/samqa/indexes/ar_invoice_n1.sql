-- liquibase formatted sql
-- changeset SAMQA:1754373929114 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_invoice_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_invoice_n1.sql:null:b4684e180ee761282c0ea328249e4ab45b6dfd68:create

create index samqa.ar_invoice_n1 on
    samqa.ar_invoice (
        acc_id
    );

