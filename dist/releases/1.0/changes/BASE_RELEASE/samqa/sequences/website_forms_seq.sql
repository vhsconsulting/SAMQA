-- liquibase formatted sql
-- changeset SAMQA:1754374150337 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\website_forms_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/website_forms_seq.sql:null:880672c7b30d268e45af7d397b298e30a8e62d04:create

create sequence samqa.website_forms_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 861 cache 20 noorder
nocycle nokeep noscale global;

