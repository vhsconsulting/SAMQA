-- liquibase formatted sql
-- changeset SAMQA:1754373943133 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.broker_revenue_hsa.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.broker_revenue_hsa.sql:null:da8e89690bfa5332cb9e703c2de6a04a1ab240c2:create

grant select on samqa.broker_revenue_hsa to rl_sam_ro;

grant select on samqa.broker_revenue_hsa to rl_sam_rw;

