-- liquibase formatted sql
-- changeset SAMQA:1754373943357 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.close_pay_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.close_pay_type.sql:null:f71d42719d46ea4d7ab5315baf299d06eeda9fcd:create

grant select on samqa.close_pay_type to rl_sam1_ro;

grant select on samqa.close_pay_type to rl_sam_rw;

grant select on samqa.close_pay_type to rl_sam_ro;

grant select on samqa.close_pay_type to sgali;

