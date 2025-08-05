-- liquibase formatted sql
-- changeset SAMQA:1754373944975 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.pop_comprehensive_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.pop_comprehensive_v.sql:null:eb549201e820c81986f232c1ab241e0afa98e50f:create

grant select on samqa.pop_comprehensive_v to rl_sam1_ro;

grant select on samqa.pop_comprehensive_v to rl_sam_rw;

grant select on samqa.pop_comprehensive_v to rl_sam_ro;

grant select on samqa.pop_comprehensive_v to sgali;

