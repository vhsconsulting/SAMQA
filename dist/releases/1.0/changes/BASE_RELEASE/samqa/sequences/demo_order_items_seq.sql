-- liquibase formatted sql
-- changeset SAMQA:1754374148287 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\demo_order_items_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/demo_order_items_seq.sql:null:b7daf54460ba81b7d5671cc3abf7890cf3076466:create

create sequence samqa.demo_order_items_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 41 cache 20 noorder
nocycle nokeep noscale global;

