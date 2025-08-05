-- liquibase formatted sql
-- changeset SAMQA:1754373945211 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.subscriber_pay_processed_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.subscriber_pay_processed_v.sql:null:fdb2535528f2e2c2cda8114aadfa32ad37b1e685:create

grant select on samqa.subscriber_pay_processed_v to rl_sam_rw;

grant select on samqa.subscriber_pay_processed_v to rl_sam_ro;

grant select on samqa.subscriber_pay_processed_v to sgali;

grant select on samqa.subscriber_pay_processed_v to rl_sam1_ro;

