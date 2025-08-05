-- liquibase formatted sql
-- changeset SAMQA:1754373945225 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.subscriber_payment_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.subscriber_payment_v.sql:null:d43044dc0becd8608e6a4bc9ed80b578bddeee76:create

grant select on samqa.subscriber_payment_v to rl_sam_rw;

grant select on samqa.subscriber_payment_v to rl_sam_ro;

grant select on samqa.subscriber_payment_v to sgali;

grant select on samqa.subscriber_payment_v to rl_sam1_ro;

