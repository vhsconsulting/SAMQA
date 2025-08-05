-- liquibase formatted sql
-- changeset SAMQA:1754373945425 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.web_expense_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.web_expense_type.sql:null:163d9cdd222e58be7dc6292b92b77a76a441bf01:create

grant select on samqa.web_expense_type to rl_sam_rw;

grant select on samqa.web_expense_type to rl_sam_ro;

grant select on samqa.web_expense_type to sgali;

grant select on samqa.web_expense_type to rl_sam1_ro;

