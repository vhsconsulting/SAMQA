-- liquibase formatted sql
-- changeset SAMQA:1754373944564 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.metavante_files_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.metavante_files_v.sql:null:c1a9f9ca6057d007fcb80db989d2940bc00460c9:create

grant select on samqa.metavante_files_v to rl_sam1_ro;

grant select on samqa.metavante_files_v to rl_sam_rw;

grant select on samqa.metavante_files_v to rl_sam_ro;

grant select on samqa.metavante_files_v to sgali;

