-- liquibase formatted sql
-- changeset SAMQA:1754374148642 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\er_balance_register_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/er_balance_register_seq.sql:null:8d5bb58f6deced3cec7eca7c0d07c2a922b553b7:create

create sequence samqa.er_balance_register_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 21 cache 20 noorder
nocycle nokeep noscale global;

