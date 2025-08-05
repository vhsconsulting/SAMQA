-- liquibase formatted sql
-- changeset SAMQA:1754373945026 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.reason_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.reason_type.sql:null:4280886a7459a2227f6e1d474b515081d514662b:create

grant select on samqa.reason_type to rl_sam1_ro;

grant select on samqa.reason_type to rl_sam_rw;

grant select on samqa.reason_type to rl_sam_ro;

grant select on samqa.reason_type to sgali;

