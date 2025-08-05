-- liquibase formatted sql
-- changeset SAMQA:1754373942634 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.type_spec.v_table_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.type_spec.v_table_type.sql:null:c68064a31cd89b52ffde8f0efc1f5cc4ca183f6d:create

grant execute on samqa.v_table_type to rl_sam1_ro;

grant execute on samqa.v_table_type to rl_sam_ro;

grant execute on samqa.v_table_type to rl_sam_rw;

