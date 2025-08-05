-- liquibase formatted sql
-- changeset SAMQA:1754373944922 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.persreg_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.persreg_v.sql:null:e075873b48fff3cfa798110fafe655aff6e328cc:create

grant select on samqa.persreg_v to rl_sam1_ro;

grant select on samqa.persreg_v to rl_sam_rw;

grant select on samqa.persreg_v to rl_sam_ro;

grant select on samqa.persreg_v to sgali;

