-- liquibase formatted sql
-- changeset SAMQA:1754373935619 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.verify_bannk_routing_num.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.verify_bannk_routing_num.sql:null:4fbf6f0ffcc37da9a9b0b9990e016cdcf4e38f51:create

grant execute on samqa.verify_bannk_routing_num to rl_sam_ro;

