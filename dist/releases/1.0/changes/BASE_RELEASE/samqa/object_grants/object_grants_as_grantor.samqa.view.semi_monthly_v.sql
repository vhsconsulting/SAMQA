-- liquibase formatted sql
-- changeset SAMQA:1754373945100 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.semi_monthly_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.semi_monthly_v.sql:null:f47a20133746a68a73978d7004536028fce30724:create

grant select on samqa.semi_monthly_v to rl_sam1_ro;

grant select on samqa.semi_monthly_v to rl_sam_rw;

grant select on samqa.semi_monthly_v to rl_sam_ro;

grant select on samqa.semi_monthly_v to sgali;

