-- liquibase formatted sql
-- changeset SAMQA:1754373943624 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.emp_overview_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.emp_overview_v.sql:null:3c8b129df37b20f74f222dac7c800a6637b73849:create

grant select on samqa.emp_overview_v to rl_sam_rw;

grant select on samqa.emp_overview_v to rl_sam_ro;

grant select on samqa.emp_overview_v to sgali;

grant select on samqa.emp_overview_v to rl_sam1_ro;

