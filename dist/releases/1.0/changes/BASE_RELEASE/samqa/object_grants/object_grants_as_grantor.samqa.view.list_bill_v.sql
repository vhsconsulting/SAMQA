-- liquibase formatted sql
-- changeset SAMQA:1754373944499 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.list_bill_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.list_bill_v.sql:null:e8a0cbd3ae5b08cfdbfa945b59edff92c24733ab:create

grant select on samqa.list_bill_v to rl_sam1_ro;

grant select on samqa.list_bill_v to rl_sam_rw;

grant select on samqa.list_bill_v to rl_sam_ro;

grant select on samqa.list_bill_v to sgali;

