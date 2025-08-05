-- liquibase formatted sql
-- changeset SAMQA:1754373940992 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.listfile_ext.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.listfile_ext.sql:null:1d67b8cf4a5d683ffd0bf1765099df503b8ca228:create

grant select on samqa.listfile_ext to rl_sam1_ro;

grant select on samqa.listfile_ext to rl_sam_ro;

