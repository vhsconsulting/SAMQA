-- liquibase formatted sql
-- changeset SAMQA:1754374149341 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\mig_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/mig_seq.sql:null:de8337da902869d83ac83b285fdb5885725cbd65:create

create sequence samqa.mig_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 11402 cache 20 noorder nocycle
nokeep noscale global;

