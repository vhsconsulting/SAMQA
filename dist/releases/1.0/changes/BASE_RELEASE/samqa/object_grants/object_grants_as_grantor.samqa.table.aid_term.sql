-- liquibase formatted sql
-- changeset SAMQA:1754373938583 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.aid_term.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.aid_term.sql:null:f49bbe21ac70c731c791c01b4549ec932333522f:create

grant delete on samqa.aid_term to rl_sam_rw;

grant insert on samqa.aid_term to rl_sam_rw;

grant select on samqa.aid_term to rl_sam1_ro;

grant select on samqa.aid_term to rl_sam_rw;

grant select on samqa.aid_term to rl_sam_ro;

grant update on samqa.aid_term to rl_sam_rw;

