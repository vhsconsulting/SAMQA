-- liquibase formatted sql
-- changeset SAMQA:1753779760714 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\ben_plan_history_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/ben_plan_history_seq.sql:null:8e983c33c8960d59cb4c1dafa127bd20b7d50f80:create

create sequence samqa.ben_plan_history_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 754707 cache 20
noorder nocycle nokeep noscale global;

