-- liquibase formatted sql
-- changeset SAMQA:1754373939096 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.broker_authorize_product_map.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.broker_authorize_product_map.sql:null:ddff0b071d51a1f26f5b6d4e1a42fc4a653ad67a:create

grant delete on samqa.broker_authorize_product_map to rl_sam_rw;

grant insert on samqa.broker_authorize_product_map to rl_sam_rw;

grant select on samqa.broker_authorize_product_map to rl_sam1_ro;

grant select on samqa.broker_authorize_product_map to rl_sam_ro;

grant select on samqa.broker_authorize_product_map to rl_sam_rw;

grant update on samqa.broker_authorize_product_map to rl_sam_rw;

