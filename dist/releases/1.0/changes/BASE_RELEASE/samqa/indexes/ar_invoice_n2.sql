-- liquibase formatted sql
-- changeset SAMQA:1754373929123 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ar_invoice_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ar_invoice_n2.sql:null:983adc7c9776e99bdd45fe2cb1dfbfdb651d0cc4:create

create index samqa.ar_invoice_n2 on
    samqa.ar_invoice (
        acc_num
    );

