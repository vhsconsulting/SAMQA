-- liquibase formatted sql
-- changeset SAMQA:1754373932799 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\payment_register_n7.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/payment_register_n7.sql:null:333c4f5cd384fe712ae7c9fa96abe5800c9e2d55:create

create index samqa.payment_register_n7 on
    samqa.payment_register (
        entrp_id
    );

