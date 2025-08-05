-- liquibase formatted sql
-- changeset SAMQA:1754373942310 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.termination_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.termination_external.sql:null:0c158f1e996ab8e9cfd9a72ca87092ac8bdb8817:create

grant select on samqa.termination_external to rl_sam1_ro;

grant select on samqa.termination_external to rl_sam_ro;

