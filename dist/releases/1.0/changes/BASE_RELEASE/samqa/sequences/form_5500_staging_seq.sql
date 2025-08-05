-- liquibase formatted sql
-- changeset SAMQA:1754374148864 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\form_5500_staging_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/form_5500_staging_seq.sql:null:4b41ed6d8bcfd348f54f348fe591f354e11eb025:create

create sequence samqa.form_5500_staging_seq minvalue 1 maxvalue 9999999999999999999999999999 increment by 1 start with 12558 cache 20
noorder nocycle nokeep noscale global;

