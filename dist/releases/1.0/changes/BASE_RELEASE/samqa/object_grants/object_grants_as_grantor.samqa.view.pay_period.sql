-- liquibase formatted sql
-- changeset SAMQA:1754373944802 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.pay_period.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.pay_period.sql:null:3d475431255f6e1b298fe07558bcedec60d7d10d:create

grant select on samqa.pay_period to rl_sam1_ro;

grant select on samqa.pay_period to rl_sam_rw;

grant select on samqa.pay_period to rl_sam_ro;

grant select on samqa.pay_period to sgali;

