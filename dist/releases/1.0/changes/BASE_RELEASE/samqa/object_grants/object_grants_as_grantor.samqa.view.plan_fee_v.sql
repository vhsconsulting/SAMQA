-- liquibase formatted sql
-- changeset SAMQA:1754373944950 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.plan_fee_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.plan_fee_v.sql:null:76a98d6bee4edadef7d75330a7f7fcbcbd0a5467:create

grant select on samqa.plan_fee_v to rl_sam1_ro;

grant select on samqa.plan_fee_v to rl_sam_rw;

grant select on samqa.plan_fee_v to rl_sam_ro;

grant select on samqa.plan_fee_v to sgali;

