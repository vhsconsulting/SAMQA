-- liquibase formatted sql
-- changeset SAMQA:1753779762888 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\rate_plans_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/rate_plans_seq.sql:null:5e259bf27fe274199ee32b9e108c491709fc0ec2:create

create sequence samqa.rate_plans_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 121987 cache 20 noorder
nocycle nokeep noscale global;

