-- liquibase formatted sql
-- changeset SAMQA:1754373935377 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_reason_name.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_reason_name.sql:null:5db1300788f1c6e9a205f79c7655d5f6d866b850:create

grant execute on samqa.get_reason_name to rl_sam_ro;

