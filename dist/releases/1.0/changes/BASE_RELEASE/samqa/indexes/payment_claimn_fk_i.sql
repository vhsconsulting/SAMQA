-- liquibase formatted sql
-- changeset SAMQA:1754373932663 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\payment_claimn_fk_i.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/payment_claimn_fk_i.sql:null:e36d6425145f62fde7528ebc6b98be08668cde31:create

create index samqa.payment_claimn_fk_i on
    samqa.payment (
        claimn_id
    );

