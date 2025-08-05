-- liquibase formatted sql
-- changeset SAMQA:1754373941500 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.opportunity_attachments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.opportunity_attachments.sql:null:11b5861e79a2873692ef07f9299c160612c17b62:create

grant select on samqa.opportunity_attachments to rl_sam_ro;

