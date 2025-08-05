-- liquibase formatted sql
-- changeset SAMQA:1754373932780 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\payment_register_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/payment_register_n5.sql:null:e9e7a49e68eefb87eacd121713dbbee2d1dbc518:create

create index samqa.payment_register_n5 on
    samqa.payment_register (
        vendor_id,
        peachtree_interfaced
    );

