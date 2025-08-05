-- liquibase formatted sql
-- changeset SAMQA:1754374148119 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\county_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/county_seq.sql:null:2f0f537f429a9a241193cd82abfe3b547e6f689c:create

create sequence samqa.county_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 53 cache 20 noorder nocycle
nokeep noscale global;

