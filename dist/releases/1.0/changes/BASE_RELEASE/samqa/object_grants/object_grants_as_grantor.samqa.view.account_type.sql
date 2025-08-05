-- liquibase formatted sql
-- changeset SAMQA:1754373942769 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.account_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.account_type.sql:null:fc1981c5984a455881396a5694806c3b9055b089:create

grant select on samqa.account_type to rl_sam1_ro;

grant select on samqa.account_type to rl_sam_rw;

grant select on samqa.account_type to rl_sam_ro;

grant select on samqa.account_type to sgali;

