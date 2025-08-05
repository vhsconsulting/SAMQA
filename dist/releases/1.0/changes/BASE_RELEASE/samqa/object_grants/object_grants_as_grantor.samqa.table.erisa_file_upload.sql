-- liquibase formatted sql
-- changeset SAMQA:1754373940357 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.erisa_file_upload.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.erisa_file_upload.sql:null:a847815b0931abbd767ea78a9e8e8e8585d8ab62:create

grant select on samqa.erisa_file_upload to rl_sam1_ro;

grant select on samqa.erisa_file_upload to rl_sam_ro;

