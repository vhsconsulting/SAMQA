-- liquibase formatted sql
-- changeset SAMQA:1754374148626 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\er_bal_register_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/er_bal_register_seq.sql:null:678082e2a680234e7994c16c2d5a0232d5440873:create

create sequence samqa.er_bal_register_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 2080916 cache 20
noorder nocycle nokeep noscale global;

