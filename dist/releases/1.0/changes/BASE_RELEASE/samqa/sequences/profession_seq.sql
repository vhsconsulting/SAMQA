-- liquibase formatted sql
-- changeset SAMQA:1754374149759 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\profession_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/profession_seq.sql:null:3366a59739e39dc42973e869bb4e18e0bcdee577:create

create sequence samqa.profession_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 51 cache 20 noorder nocycle
nokeep noscale global;

