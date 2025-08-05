-- liquibase formatted sql
-- changeset SAMQA:1754374147565 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\balance_register_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/balance_register_seq.sql:null:80ab290644eb6c4fefabcf4224285c6197306ba4:create

create sequence samqa.balance_register_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 62217955 cache 20
noorder nocycle nokeep noscale global;

