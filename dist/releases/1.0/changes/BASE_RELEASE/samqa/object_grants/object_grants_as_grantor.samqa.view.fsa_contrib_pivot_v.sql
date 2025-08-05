-- liquibase formatted sql
-- changeset SAMQA:1754373943959 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_contrib_pivot_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_contrib_pivot_v.sql:null:b0e8578eac3da60006e80c37a8d0df5f373fbcf9:create

grant select on samqa.fsa_contrib_pivot_v to rl_sam1_ro;

grant select on samqa.fsa_contrib_pivot_v to rl_sam_rw;

grant select on samqa.fsa_contrib_pivot_v to rl_sam_ro;

grant select on samqa.fsa_contrib_pivot_v to sgali;

