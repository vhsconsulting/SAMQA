-- liquibase formatted sql
-- changeset SAMQA:1754373942880 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.agile_payments_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.agile_payments_v.sql:null:3a4786d77cbc7dcc6d414e2499c53fc8b8eb7ab9:create

grant select on samqa.agile_payments_v to rl_sam1_ro;

grant select on samqa.agile_payments_v to rl_sam_ro;

grant select on samqa.agile_payments_v to rl_sam_rw;

