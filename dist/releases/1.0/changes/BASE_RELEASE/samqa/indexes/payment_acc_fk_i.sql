-- liquibase formatted sql
-- changeset SAMQA:1754373932655 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\payment_acc_fk_i.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/payment_acc_fk_i.sql:null:c2d0ea51a5ae2d1683756b98b577b2d5aaefbb3c:create

create index samqa.payment_acc_fk_i on
    samqa.payment (
        acc_id
    );

