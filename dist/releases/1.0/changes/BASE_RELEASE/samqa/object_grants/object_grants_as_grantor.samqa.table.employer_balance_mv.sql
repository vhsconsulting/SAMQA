-- liquibase formatted sql
-- changeset SAMQA:1754373939887 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.employer_balance_mv.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.employer_balance_mv.sql:null:1dda12bf14e5a31ce4118cc0349e17f1bea2630b:create

grant select on samqa.employer_balance_mv to rl_sam_ro;

