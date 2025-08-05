-- liquibase formatted sql
-- changeset SAMQA:1754373942639 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.type_spec.v_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.type_spec.v_type.sql:null:50edffae7d9982e9896d330446476c7c0e6a5ea1:create

grant execute on samqa.v_type to rl_sam1_ro;

grant execute on samqa.v_type to rl_sam_ro;

grant execute on samqa.v_type to rl_sam_rw;

