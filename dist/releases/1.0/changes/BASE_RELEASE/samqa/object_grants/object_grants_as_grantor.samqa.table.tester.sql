-- liquibase formatted sql
-- changeset SAMQA:1754373942327 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.tester.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.tester.sql:null:616a552d9cbcdad0b5f21e5c0351ebe1bea9425c:create

grant delete on samqa.tester to rl_sam_rw;

grant insert on samqa.tester to rl_sam_rw;

grant select on samqa.tester to rl_sam1_ro;

grant select on samqa.tester to rl_sam_ro;

grant select on samqa.tester to rl_sam_rw;

grant update on samqa.tester to rl_sam_rw;

