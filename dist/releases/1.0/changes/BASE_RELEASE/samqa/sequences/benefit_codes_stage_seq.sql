-- liquibase formatted sql
-- changeset SAMQA:1754374147689 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\benefit_codes_stage_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/benefit_codes_stage_seq.sql:null:c07f97ba4c6fdac7a21ddae3758951c68a96ded0:create

create sequence samqa.benefit_codes_stage_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 1 cache 20 noorder
nocycle nokeep noscale global;

