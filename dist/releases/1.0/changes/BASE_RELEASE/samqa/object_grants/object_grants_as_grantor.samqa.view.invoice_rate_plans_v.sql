-- liquibase formatted sql
-- changeset SAMQA:1754373944490 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.invoice_rate_plans_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.invoice_rate_plans_v.sql:null:33431550ab4ef3fe507fe487bbf0dc257aa97bff:create

grant select on samqa.invoice_rate_plans_v to rl_sam1_ro;

grant select on samqa.invoice_rate_plans_v to rl_sam_ro;

grant select on samqa.invoice_rate_plans_v to rl_sam_rw;

