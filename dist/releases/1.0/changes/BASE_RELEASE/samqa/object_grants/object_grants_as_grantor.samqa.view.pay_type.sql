-- liquibase formatted sql
-- changeset SAMQA:1754373944818 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.pay_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.pay_type.sql:null:dcbdfcb6451675b65349073995f2c921f2d4fd93:create

grant select on samqa.pay_type to rl_sam1_ro;

grant select on samqa.pay_type to rl_sam_rw;

grant select on samqa.pay_type to rl_sam_ro;

grant select on samqa.pay_type to sgali;

