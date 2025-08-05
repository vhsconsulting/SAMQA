-- liquibase formatted sql
-- changeset SAMQA:1754373942599 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.type_spec.number_table.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.type_spec.number_table.sql:null:ffbac60b05677d620073b126009e7925feb841a5:create

grant execute on samqa.number_table to rl_sam1_ro;

grant execute on samqa.number_table to rl_sam_ro;

grant execute on samqa.number_table to rl_sam_rw;

