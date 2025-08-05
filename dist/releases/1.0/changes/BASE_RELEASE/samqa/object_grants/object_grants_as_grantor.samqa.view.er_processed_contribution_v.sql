-- liquibase formatted sql
-- changeset SAMQA:1754373943845 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.er_processed_contribution_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.er_processed_contribution_v.sql:null:25d8687a79b03beec1bae0d7ad62c220a7185c0e:create

grant select on samqa.er_processed_contribution_v to rl_sam1_ro;

grant select on samqa.er_processed_contribution_v to rl_sam_rw;

grant select on samqa.er_processed_contribution_v to rl_sam_ro;

grant select on samqa.er_processed_contribution_v to sgali;

