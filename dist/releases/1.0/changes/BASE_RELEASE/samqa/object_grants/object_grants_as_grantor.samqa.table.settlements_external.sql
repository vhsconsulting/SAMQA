-- liquibase formatted sql
-- changeset SAMQA:1754373942145 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.settlements_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.settlements_external.sql:null:f56ccaed600d7ee0b31971dc0b5f24a0a59b1eb8:create

grant select on samqa.settlements_external to rl_sam1_ro;

grant select on samqa.settlements_external to rl_sam_ro;

