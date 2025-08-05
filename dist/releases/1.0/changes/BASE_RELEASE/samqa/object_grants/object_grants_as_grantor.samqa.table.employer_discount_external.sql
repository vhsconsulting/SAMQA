-- liquibase formatted sql
-- changeset SAMQA:1754373939919 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.employer_discount_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.employer_discount_external.sql:null:f9b613e78f1b745a1127f1bcfa5e2c2b567e5271:create

grant alter on samqa.employer_discount_external to public;

grant select on samqa.employer_discount_external to rl_sam1_ro;

grant select on samqa.employer_discount_external to public;

grant select on samqa.employer_discount_external to rl_sam_ro;

grant read on samqa.employer_discount_external to public;

