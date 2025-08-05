-- liquibase formatted sql
-- changeset SAMQA:1754373939789 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.dept.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.dept.sql:null:43493c70d4a54189ddf3fe1a03d2da1320253617:create

grant select on samqa.dept to rl_sam_ro;

