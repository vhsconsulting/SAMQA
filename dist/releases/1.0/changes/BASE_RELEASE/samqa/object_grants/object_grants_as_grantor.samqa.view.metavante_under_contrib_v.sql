-- liquibase formatted sql
-- changeset SAMQA:1754373944577 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.metavante_under_contrib_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.metavante_under_contrib_v.sql:null:15adc2f271cc7d213cff10acf9a0a394cf76f629:create

grant select on samqa.metavante_under_contrib_v to rl_sam1_ro;

grant select on samqa.metavante_under_contrib_v to rl_sam_rw;

grant select on samqa.metavante_under_contrib_v to rl_sam_ro;

grant select on samqa.metavante_under_contrib_v to sgali;

