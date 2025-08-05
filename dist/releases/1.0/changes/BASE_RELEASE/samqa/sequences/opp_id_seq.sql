-- liquibase formatted sql
-- changeset SAMQA:1754374149576 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\opp_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/opp_id_seq.sql:null:96a0c51a8ce83bc34812e711c68e09bb182f31e0:create

create sequence samqa.opp_id_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 5524 cache 20 noorder nocycle
nokeep noscale global;

