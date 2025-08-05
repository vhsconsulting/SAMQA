-- liquibase formatted sql
-- changeset SAMQA:1754373944992 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.processed_contribution_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.processed_contribution_v.sql:null:7955b7a203660cb639f5c68112797f7c8c39e2a1:create

grant select on samqa.processed_contribution_v to rl_sam1_ro;

grant select on samqa.processed_contribution_v to rl_sam_rw;

grant select on samqa.processed_contribution_v to rl_sam_ro;

grant select on samqa.processed_contribution_v to sgali;

