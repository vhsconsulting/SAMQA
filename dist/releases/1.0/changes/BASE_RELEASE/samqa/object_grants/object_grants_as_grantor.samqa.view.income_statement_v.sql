-- liquibase formatted sql
-- changeset SAMQA:1754373944399 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.income_statement_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.income_statement_v.sql:null:4cc4016a79142683ff739aff05dd2d7469f3cfd0:create

grant select on samqa.income_statement_v to rl_sam1_ro;

grant select on samqa.income_statement_v to rl_sam_rw;

grant select on samqa.income_statement_v to rl_sam_ro;

grant select on samqa.income_statement_v to sgali;

