-- liquibase formatted sql
-- changeset SAMQA:1754373944570 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.metavante_over_contrib_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.metavante_over_contrib_v.sql:null:65a450be58a5292b94088a8e10f0903a0cef2993:create

grant select on samqa.metavante_over_contrib_v to rl_sam1_ro;

grant select on samqa.metavante_over_contrib_v to rl_sam_rw;

grant select on samqa.metavante_over_contrib_v to rl_sam_ro;

grant select on samqa.metavante_over_contrib_v to sgali;

