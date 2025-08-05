-- liquibase formatted sql
-- changeset SAMQA:1754374159014 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\gp_customer_account_gt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/gp_customer_account_gt.sql:null:c4d1151b03273ff672562f708f17f27c6e133ac1:create

create global temporary table samqa.gp_customer_account_gt (
    customer_id   varchar2(255 byte),
    customer_name varchar2(3000 byte),
    class_id      varchar2(255 byte),
    stacked       varchar2(255 byte),
    account_type  varchar2(255 byte),
    acc_id        number,
    status        varchar2(255 byte),
    customer_type varchar2(100 byte),
    entrp_id      number,
    pers_id       number
) on commit preserve rows;

