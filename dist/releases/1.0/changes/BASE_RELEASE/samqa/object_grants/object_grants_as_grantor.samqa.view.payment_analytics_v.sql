-- liquibase formatted sql
-- changeset SAMQA:1754373944834 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.payment_analytics_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.payment_analytics_v.sql:null:7d036c76cf6ff6752f1c270d06ea20be31000c8f:create

grant select on samqa.payment_analytics_v to rl_sam1_ro;

grant select on samqa.payment_analytics_v to rl_sam_rw;

grant select on samqa.payment_analytics_v to rl_sam_ro;

grant select on samqa.payment_analytics_v to sgali;

