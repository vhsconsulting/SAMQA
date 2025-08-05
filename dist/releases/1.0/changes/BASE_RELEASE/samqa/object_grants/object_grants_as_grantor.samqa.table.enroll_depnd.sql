-- liquibase formatted sql
-- changeset SAMQA:1754373940089 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.enroll_depnd.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.enroll_depnd.sql:null:aff366a67a0dc9b7e55ba7453f7cf8ac70702354:create

grant select on samqa.enroll_depnd to rl_sam1_ro;

grant select on samqa.enroll_depnd to rl_sam_ro;

