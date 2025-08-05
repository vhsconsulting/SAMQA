-- liquibase formatted sql
-- changeset SAMQA:1754373942065 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.scheduler_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.scheduler_external.sql:null:900ff612fdf5659415a8d562563ca5919fa085de:create

grant select on samqa.scheduler_external to rl_sam1_ro;

grant select on samqa.scheduler_external to rl_sam_ro;

