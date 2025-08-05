-- liquibase formatted sql
-- changeset SAMQA:1754373940472 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.feedback.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.feedback.sql:null:b1de82db47b602559b36fc0cfc2065ac92feace9:create

grant alter on samqa.feedback to rl_sam_rw;

grant insert on samqa.feedback to rl_sam_rw;

grant select on samqa.feedback to rl_sam_rw;

grant select on samqa.feedback to rl_sam_ro;

grant update on samqa.feedback to rl_sam_rw;

grant read on samqa.feedback to rl_sam_ro;

grant read on samqa.feedback to rl_sam_rw;

