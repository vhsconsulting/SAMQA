-- liquibase formatted sql
-- changeset SAMQA:1754373941118 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.metavante_authorizations.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.metavante_authorizations.sql:null:b0eea67c353fbd254ebc5763095649360d8ca378:create

grant delete on samqa.metavante_authorizations to rl_sam_rw;

grant insert on samqa.metavante_authorizations to rl_sam_rw;

grant select on samqa.metavante_authorizations to rl_sam1_ro;

grant select on samqa.metavante_authorizations to rl_sam_rw;

grant select on samqa.metavante_authorizations to rl_sam_ro;

grant update on samqa.metavante_authorizations to rl_sam_rw;

