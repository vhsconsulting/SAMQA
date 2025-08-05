-- liquibase formatted sql
-- changeset SAMQA:1754373943965 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_contributions_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_contributions_v.sql:null:30d1404d032a7b49e418ae0b4d7c094f99eb8826:create

grant select on samqa.fsa_contributions_v to rl_sam1_ro;

grant select on samqa.fsa_contributions_v to rl_sam_rw;

grant select on samqa.fsa_contributions_v to rl_sam_ro;

grant select on samqa.fsa_contributions_v to sgali;

