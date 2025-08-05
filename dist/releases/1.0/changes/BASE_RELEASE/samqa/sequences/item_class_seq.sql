-- liquibase formatted sql
-- changeset SAMQA:1754374149134 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\item_class_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/item_class_seq.sql:null:493dbf6f2188ccce2554ea18074c403d0a4fcd2f:create

create sequence samqa.item_class_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 81 cache 20 noorder nocycle
nokeep noscale global;

