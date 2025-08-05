-- liquibase formatted sql
-- changeset SAMQA:1754374149561 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\opp_history_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/opp_history_id_seq.sql:null:387d84bd407822ce5de214a1a8152a3a878fd787:create

create sequence samqa.opp_history_id_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 7390 cache 20 noorder
nocycle nokeep noscale global;

