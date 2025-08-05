-- liquibase formatted sql
-- changeset SAMQA:1754373945192 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.subscriber_pay_cancelled_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.subscriber_pay_cancelled_v.sql:null:d7629ed393f2415f62339978ef603a4c1b0cebce:create

grant select on samqa.subscriber_pay_cancelled_v to rl_sam_rw;

grant select on samqa.subscriber_pay_cancelled_v to rl_sam_ro;

grant select on samqa.subscriber_pay_cancelled_v to sgali;

grant select on samqa.subscriber_pay_cancelled_v to rl_sam1_ro;

