-- liquibase formatted sql
-- changeset SAMQA:1754373945007 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.provider_payment_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.provider_payment_v.sql:null:47e6764fd2acbefe7ff70a78b5465d3c68fe78f5:create

grant select on samqa.provider_payment_v to rl_sam_rw;

grant select on samqa.provider_payment_v to rl_sam_ro;

grant select on samqa.provider_payment_v to sgali;

grant select on samqa.provider_payment_v to rl_sam1_ro;

