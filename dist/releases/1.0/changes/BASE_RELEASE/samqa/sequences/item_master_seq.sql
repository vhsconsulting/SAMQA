-- liquibase formatted sql
-- changeset SAMQA:1754374149134 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\item_master_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/item_master_seq.sql:null:2ba196c629dd0263d2ddaed6002a35f9b3f6a912:create

create sequence samqa.item_master_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 101 cache 20 noorder
nocycle nokeep noscale global;

