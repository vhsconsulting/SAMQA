-- liquibase formatted sql
-- changeset SAMQA:1754373944958 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.plan_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.plan_type.sql:null:5a492989cdca5577803c8a629017876f2342ce31:create

grant select on samqa.plan_type to rl_sam1_ro;

grant select on samqa.plan_type to rl_sam_rw;

grant select on samqa.plan_type to rl_sam_ro;

grant select on samqa.plan_type to sgali;

