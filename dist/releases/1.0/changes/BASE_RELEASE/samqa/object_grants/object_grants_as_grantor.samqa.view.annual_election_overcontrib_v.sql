-- liquibase formatted sql
-- changeset SAMQA:1754373942895 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.annual_election_overcontrib_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.annual_election_overcontrib_v.sql:null:fde811999fadd5abf04c7349267aaf317cf9bd74:create

grant select on samqa.annual_election_overcontrib_v to rl_sam1_ro;

grant select on samqa.annual_election_overcontrib_v to rl_sam_rw;

grant select on samqa.annual_election_overcontrib_v to rl_sam_ro;

