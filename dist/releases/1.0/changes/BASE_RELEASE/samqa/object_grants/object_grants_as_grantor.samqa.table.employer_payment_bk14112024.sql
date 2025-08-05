-- liquibase formatted sql
-- changeset SAMQA:1754373939988 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.employer_payment_bk14112024.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.employer_payment_bk14112024.sql:null:a8da832b0bcbbc4c59cd88565318a9b276bcaec5:create

grant select on samqa.employer_payment_bk14112024 to rl_sam_ro;

