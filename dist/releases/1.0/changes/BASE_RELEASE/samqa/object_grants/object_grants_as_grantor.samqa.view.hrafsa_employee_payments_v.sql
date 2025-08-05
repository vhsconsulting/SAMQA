-- liquibase formatted sql
-- changeset SAMQA:1754373944332 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.hrafsa_employee_payments_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.hrafsa_employee_payments_v.sql:null:80acaab883485cb59e25362566eb7fb7411b20b6:create

grant select on samqa.hrafsa_employee_payments_v to rl_sam1_ro;

grant select on samqa.hrafsa_employee_payments_v to rl_sam_rw;

grant select on samqa.hrafsa_employee_payments_v to rl_sam_ro;

grant select on samqa.hrafsa_employee_payments_v to sgali;

