-- liquibase formatted sql
-- changeset SAMQA:1754373944210 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.getbrokerperiod.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.getbrokerperiod.sql:null:0cf6894fcbf82ae3547231360137aa786241df86:create

grant select on samqa.getbrokerperiod to rl_sam1_ro;

grant select on samqa.getbrokerperiod to rl_sam_rw;

grant select on samqa.getbrokerperiod to rl_sam_ro;

grant select on samqa.getbrokerperiod to sgali;

