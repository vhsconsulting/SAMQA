-- liquibase formatted sql
-- changeset SAMQA:1754373941508 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.opportunity_notes.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.opportunity_notes.sql:null:caafa29e2f19ad92012c2caa9a4b9bb86ef04f50:create

grant select on samqa.opportunity_notes to rl_sam_ro;

