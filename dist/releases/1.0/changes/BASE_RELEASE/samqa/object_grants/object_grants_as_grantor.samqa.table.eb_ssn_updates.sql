-- liquibase formatted sql
-- changeset SAMQA:1754373939825 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.eb_ssn_updates.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.eb_ssn_updates.sql:null:5569e77c5735fec82d270895b3043278af7a6d09:create

grant delete on samqa.eb_ssn_updates to rl_sam_rw;

grant insert on samqa.eb_ssn_updates to rl_sam_rw;

grant select on samqa.eb_ssn_updates to rl_sam1_ro;

grant select on samqa.eb_ssn_updates to rl_sam_rw;

grant select on samqa.eb_ssn_updates to rl_sam_ro;

grant update on samqa.eb_ssn_updates to rl_sam_rw;

