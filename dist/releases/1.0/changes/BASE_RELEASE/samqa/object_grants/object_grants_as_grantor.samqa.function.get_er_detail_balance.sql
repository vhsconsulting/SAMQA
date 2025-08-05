-- liquibase formatted sql
-- changeset SAMQA:1754373935285 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.get_er_detail_balance.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.get_er_detail_balance.sql:null:7e5f20f86156d3fb78681f6372535fe9f3bb43cd:create

grant execute on samqa.get_er_detail_balance to rl_sam_ro;

