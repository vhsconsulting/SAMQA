-- liquibase formatted sql
-- changeset SAMQA:1754373939560 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.creditcard_response_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.creditcard_response_detail.sql:null:3771d59628d1477eb646be42497395839164178f:create

grant select on samqa.creditcard_response_detail to rl_sam_ro;

