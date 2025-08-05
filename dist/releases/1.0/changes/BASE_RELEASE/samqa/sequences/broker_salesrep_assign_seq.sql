-- liquibase formatted sql
-- changeset SAMQA:1754374147738 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\broker_salesrep_assign_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/broker_salesrep_assign_seq.sql:null:404d7a1a6f98458c439f95f7a50e22b4a725965d:create

create sequence samqa.broker_salesrep_assign_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 23964 cache
20 noorder nocycle nokeep noscale global;

