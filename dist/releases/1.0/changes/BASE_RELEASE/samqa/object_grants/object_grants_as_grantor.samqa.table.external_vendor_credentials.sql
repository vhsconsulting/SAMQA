-- liquibase formatted sql
-- changeset SAMQA:1754373940414 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.external_vendor_credentials.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.external_vendor_credentials.sql:null:9ef38d68a65da3333f0784d37fbfa11a27538843:create

grant delete on samqa.external_vendor_credentials to rl_sam_rw;

grant insert on samqa.external_vendor_credentials to rl_sam_rw;

grant select on samqa.external_vendor_credentials to rl_sam1_ro;

grant select on samqa.external_vendor_credentials to rl_sam_rw;

grant select on samqa.external_vendor_credentials to rl_sam_ro;

grant update on samqa.external_vendor_credentials to rl_sam_rw;

