-- liquibase formatted sql
-- changeset SAMQA:1754373943139 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.broker_revenue_no_hsa.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.broker_revenue_no_hsa.sql:null:19a3d75795a83ae1c87a042f3e9292c8f933dd83:create

grant select on samqa.broker_revenue_no_hsa to rl_sam_rw;

grant select on samqa.broker_revenue_no_hsa to rl_sam_ro;

