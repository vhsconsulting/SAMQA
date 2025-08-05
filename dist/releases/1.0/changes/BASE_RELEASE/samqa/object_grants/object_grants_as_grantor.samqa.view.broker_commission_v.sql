-- liquibase formatted sql
-- changeset SAMQA:1754373943079 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.broker_commission_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.broker_commission_v.sql:null:0d6643395786ea3269ff13db9278c71b0a3637ab:create

grant select on samqa.broker_commission_v to rl_sam1_ro;

grant select on samqa.broker_commission_v to rl_sam_rw;

grant select on samqa.broker_commission_v to rl_sam_ro;

grant select on samqa.broker_commission_v to sgali;

