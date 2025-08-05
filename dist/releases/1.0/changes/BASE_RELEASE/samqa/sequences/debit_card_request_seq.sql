-- liquibase formatted sql
-- changeset SAMQA:1754374148190 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\debit_card_request_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/debit_card_request_seq.sql:null:0184841ee2f634fd6362545486fa86b25f1ec272:create

create sequence samqa.debit_card_request_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 123914892 cache
20 noorder nocycle nokeep noscale global;

