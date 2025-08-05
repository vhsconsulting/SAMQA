-- liquibase formatted sql
-- changeset SAMQA:1754373939388 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.cms_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.cms_external.sql:null:c86d22756509bf9daec7c0b6ea870aaee85cfbcd:create

grant select on samqa.cms_external to rl_sam1_ro;

grant select on samqa.cms_external to rl_sam_ro;

