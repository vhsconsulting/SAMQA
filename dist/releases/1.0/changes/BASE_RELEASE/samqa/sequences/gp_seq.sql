-- liquibase formatted sql
-- changeset SAMQA:1754374148927 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\gp_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/gp_seq.sql:null:5f47163fcda233cc3f67c19978cabfd2da82b279:create

create sequence samqa.gp_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 521 cache 20 noorder nocycle nokeep
noscale global;

