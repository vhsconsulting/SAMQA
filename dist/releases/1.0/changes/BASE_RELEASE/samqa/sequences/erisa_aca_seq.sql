-- liquibase formatted sql
-- changeset SAMQA:1753779761746 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\erisa_aca_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/erisa_aca_seq.sql:null:00f03f258a6ef0f18036c5bd321a3408b89035a6:create

create sequence samqa.erisa_aca_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 23345 cache 20 noorder
nocycle nokeep noscale global;

