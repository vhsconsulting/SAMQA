-- liquibase formatted sql
-- changeset SAMQA:1754373942462 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.vendor_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.vendor_external.sql:null:24ee2c4830c104eaf79f0f2f29275d78f57047d4:create

grant select on samqa.vendor_external to rl_sam1_ro;

grant select on samqa.vendor_external to rl_sam_ro;

