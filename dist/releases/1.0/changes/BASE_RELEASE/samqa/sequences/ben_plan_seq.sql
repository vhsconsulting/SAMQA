-- liquibase formatted sql
-- changeset SAMQA:1754374147640 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\ben_plan_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/ben_plan_seq.sql:null:fa9b3f7bdbba387e3c649d2769f61b343b5031b1:create

create sequence samqa.ben_plan_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 893979 cache 20 noorder nocycle
nokeep noscale global;

