-- liquibase formatted sql
-- changeset SAMQA:1754374157772 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\er_balance_gt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/er_balance_gt.sql:null:01487527ba2cf53db5a6d288226fbc7adb184420:create

create table samqa.er_balance_gt (
    entrp_id     number,
    sam_bal      number,
    or_bal       number,
    ord_no       number,
    product_type varchar2(3200 byte)
);

