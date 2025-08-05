-- liquibase formatted sql
-- changeset SAMQA:1754374147677 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\benefit_codes_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/benefit_codes_seq.sql:null:855a6a974ffb309ffb383c9ef62830bdd189bce2:create

create sequence samqa.benefit_codes_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 150732 cache 20 noorder
nocycle nokeep noscale global;

