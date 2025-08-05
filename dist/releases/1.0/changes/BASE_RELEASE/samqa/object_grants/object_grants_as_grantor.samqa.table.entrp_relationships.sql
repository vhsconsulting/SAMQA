-- liquibase formatted sql
-- changeset SAMQA:1754373940200 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.entrp_relationships.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.entrp_relationships.sql:null:4b2629b0a8a70291cb99da4bdb5b2f7657aa12c9:create

grant delete on samqa.entrp_relationships to rl_sam_rw;

grant insert on samqa.entrp_relationships to rl_sam_rw;

grant select on samqa.entrp_relationships to rl_sam1_ro;

grant select on samqa.entrp_relationships to rl_sam_rw;

grant select on samqa.entrp_relationships to rl_sam_ro;

grant update on samqa.entrp_relationships to rl_sam_rw;

