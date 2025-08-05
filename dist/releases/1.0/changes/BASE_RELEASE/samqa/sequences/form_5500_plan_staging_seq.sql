-- liquibase formatted sql
-- changeset SAMQA:1754374148848 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\form_5500_plan_staging_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/form_5500_plan_staging_seq.sql:null:4c9799d7a7cbb2c87cdc3bfaae3c7ef558e4b4a4:create

create sequence samqa.form_5500_plan_staging_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 131290 cache
20 noorder nocycle nokeep noscale global;

