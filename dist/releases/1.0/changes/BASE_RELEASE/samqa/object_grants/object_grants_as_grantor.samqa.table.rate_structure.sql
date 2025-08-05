-- liquibase formatted sql
-- changeset SAMQA:1754373941818 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.rate_structure.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.rate_structure.sql:null:fd6e8b04c001f1c9f731151899fc1cb42cf96cbb:create

grant delete on samqa.rate_structure to rl_sam_rw;

grant insert on samqa.rate_structure to rl_sam_rw;

grant select on samqa.rate_structure to rl_sam1_ro;

grant select on samqa.rate_structure to rl_sam_rw;

grant select on samqa.rate_structure to rl_sam_ro;

grant update on samqa.rate_structure to rl_sam_rw;

