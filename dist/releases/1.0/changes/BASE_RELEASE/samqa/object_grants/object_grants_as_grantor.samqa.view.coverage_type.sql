-- liquibase formatted sql
-- changeset SAMQA:1754373943433 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.coverage_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.coverage_type.sql:null:c4c453ba9c98448dda3e9f7e1aba9f6400f50064:create

grant select on samqa.coverage_type to rl_sam1_ro;

grant select on samqa.coverage_type to rl_sam_rw;

grant select on samqa.coverage_type to rl_sam_ro;

grant select on samqa.coverage_type to sgali;

