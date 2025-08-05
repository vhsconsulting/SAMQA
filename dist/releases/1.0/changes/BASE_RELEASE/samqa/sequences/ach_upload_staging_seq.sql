-- liquibase formatted sql
-- changeset SAMQA:1754374147414 stripComments:false logicalFilePath:BASE_RELEASE\samqa\sequences\ach_upload_staging_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/sequences/ach_upload_staging_seq.sql:null:8f6e1ca8fdea7f1d47e41e7f3d60871002f86433:create

create sequence samqa.ach_upload_staging_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 1121048 cache 20
noorder nocycle nokeep noscale global;

