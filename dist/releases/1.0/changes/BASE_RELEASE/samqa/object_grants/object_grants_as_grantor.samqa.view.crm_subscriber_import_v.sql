-- liquibase formatted sql
-- changeset SAMQA:1754373943462 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.crm_subscriber_import_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.crm_subscriber_import_v.sql:null:bc4d50a6a02f3499febde57793087349379ac911:create

grant select on samqa.crm_subscriber_import_v to rl_sam1_ro;

grant select on samqa.crm_subscriber_import_v to rl_sam_ro;

grant select on samqa.crm_subscriber_import_v to rl_sam_rw;

