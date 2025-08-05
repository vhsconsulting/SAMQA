-- liquibase formatted sql
-- changeset SAMQA:1754374147865 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\checks_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/checks_seq.sql:null:8c321cbf15f8f1ad9294d0be903a2f3fd6c6bb03:create

create sequence samqa.checks_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 721617 cache 20 noorder nocycle
nokeep noscale global;

