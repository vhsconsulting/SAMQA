-- liquibase formatted sql
-- changeset SAMQA:1753779760727 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\ben_plan_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/ben_plan_seq.sql:null:a903af7ae50029004439930835829382934aef36:create

create sequence samqa.ben_plan_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 893919 cache 20 noorder nocycle
nokeep noscale global;

