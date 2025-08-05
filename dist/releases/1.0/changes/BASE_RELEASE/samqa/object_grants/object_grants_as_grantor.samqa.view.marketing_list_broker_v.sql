-- liquibase formatted sql
-- changeset SAMQA:1754373944538 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.marketing_list_broker_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.marketing_list_broker_v.sql:null:129c8f13e1d9f9907368d8100e2cd7e3a7d6ac38:create

grant select on samqa.marketing_list_broker_v to rl_sam1_ro;

grant select on samqa.marketing_list_broker_v to rl_sam_rw;

grant select on samqa.marketing_list_broker_v to rl_sam_ro;

grant select on samqa.marketing_list_broker_v to sgali;

