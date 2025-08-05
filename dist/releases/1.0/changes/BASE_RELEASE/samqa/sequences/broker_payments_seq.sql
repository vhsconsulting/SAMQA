-- liquibase formatted sql
-- changeset SAMQA:1754374147725 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\broker_payments_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/broker_payments_seq.sql:null:d0dd0262220d9ed0cd04bbb4a342b80456638a2c:create

create sequence samqa.broker_payments_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 23062 cache 20 noorder
nocycle nokeep noscale global;

