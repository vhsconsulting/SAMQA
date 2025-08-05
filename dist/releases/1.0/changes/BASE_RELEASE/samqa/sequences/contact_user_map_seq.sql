-- liquibase formatted sql
-- changeset SAMQA:1754374148106 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\contact_user_map_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/contact_user_map_seq.sql:null:adcf73a1f52a9bf26416f2fdf1640aa0cdbd6343:create

create sequence samqa.contact_user_map_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 137915 cache 20
noorder nocycle nokeep noscale global;

