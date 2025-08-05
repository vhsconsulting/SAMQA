-- liquibase formatted sql
-- changeset SAMQA:1754374149984 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\salesrep_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/salesrep_seq.sql:null:5192d805ba09f8c4ad731563378e7618d9c4dd91:create

create sequence samqa.salesrep_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 2662 cache 20 noorder nocycle
nokeep noscale global;

