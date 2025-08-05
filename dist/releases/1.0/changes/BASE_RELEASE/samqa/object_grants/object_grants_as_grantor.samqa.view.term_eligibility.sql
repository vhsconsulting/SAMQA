-- liquibase formatted sql
-- changeset SAMQA:1754373945331 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.term_eligibility.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.term_eligibility.sql:null:d44a2f1d04725bfdcd109753c04967e28c5b06a8:create

grant select on samqa.term_eligibility to rl_sam_rw;

grant select on samqa.term_eligibility to rl_sam_ro;

grant select on samqa.term_eligibility to sgali;

grant select on samqa.term_eligibility to rl_sam1_ro;

