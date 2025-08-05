-- liquibase formatted sql
-- changeset SAMQA:1754373945203 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.subscriber_pay_pending_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.subscriber_pay_pending_v.sql:null:ed934de76d79e31f76a26279268e773ed7adef1e:create

grant select on samqa.subscriber_pay_pending_v to rl_sam_rw;

grant select on samqa.subscriber_pay_pending_v to rl_sam_ro;

grant select on samqa.subscriber_pay_pending_v to sgali;

grant select on samqa.subscriber_pay_pending_v to rl_sam1_ro;

