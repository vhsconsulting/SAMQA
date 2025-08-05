-- liquibase formatted sql
-- changeset SAMQA:1754373943456 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.crm_import_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.crm_import_v.sql:null:0728e3f65f374d34c41024921aa0020ac2829653:create

grant select on samqa.crm_import_v to rl_sam1_ro;

grant select on samqa.crm_import_v to rl_sam_rw;

grant select on samqa.crm_import_v to rl_sam_ro;

grant select on samqa.crm_import_v to sgali;

