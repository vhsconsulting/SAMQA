-- liquibase formatted sql
-- changeset SAMQA:1754373942738 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.account_aggregate_view.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.account_aggregate_view.sql:null:8dd5bc850511ef0669cb4eea8b5f43f30ab2858f:create

grant select on samqa.account_aggregate_view to rl_sam1_ro;

grant select on samqa.account_aggregate_view to rl_sam_ro;

grant select on samqa.account_aggregate_view to rl_sam_rw;

