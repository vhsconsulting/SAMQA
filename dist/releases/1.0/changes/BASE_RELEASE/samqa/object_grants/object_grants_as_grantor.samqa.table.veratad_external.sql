-- liquibase formatted sql
-- changeset SAMQA:1754373942492 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.veratad_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.veratad_external.sql:null:39aedec241bc23b18b3be00e3177c13ebce25507:create

grant select on samqa.veratad_external to rl_sam1_ro;

grant select on samqa.veratad_external to rl_sam_ro;

