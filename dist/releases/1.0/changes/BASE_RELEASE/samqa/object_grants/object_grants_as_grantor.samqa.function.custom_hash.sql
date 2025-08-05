-- liquibase formatted sql
-- changeset SAMQA:1754373935174 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.custom_hash.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.custom_hash.sql:null:05bc609e047ed8c4af86d2393ee453df28627056:create

grant execute on samqa.custom_hash to rl_sam_ro;

