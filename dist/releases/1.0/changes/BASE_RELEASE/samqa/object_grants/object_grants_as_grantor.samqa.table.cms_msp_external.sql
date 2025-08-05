-- liquibase formatted sql
-- changeset SAMQA:1754373939392 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.cms_msp_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.cms_msp_external.sql:null:29bc479417e2b089e3a16d9618bb2e981dd63d04:create

grant select on samqa.cms_msp_external to rl_sam1_ro;

grant select on samqa.cms_msp_external to rl_sam_ro;

