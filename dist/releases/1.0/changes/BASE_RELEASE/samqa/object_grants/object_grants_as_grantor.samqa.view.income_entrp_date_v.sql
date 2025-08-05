-- liquibase formatted sql
-- changeset SAMQA:1754373944394 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.income_entrp_date_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.income_entrp_date_v.sql:null:8f6bf52bc0594b81c9ffbaf6bfc73094f17e3a5f:create

grant select on samqa.income_entrp_date_v to rl_sam1_ro;

grant select on samqa.income_entrp_date_v to rl_sam_rw;

grant select on samqa.income_entrp_date_v to rl_sam_ro;

grant select on samqa.income_entrp_date_v to sgali;

