-- liquibase formatted sql
-- changeset SAMQA:1754373943707 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.employer_enrollment_pdf_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.employer_enrollment_pdf_v.sql:null:6129d20f3e2f68174f536e85796be3fb7ab79815:create

grant select on samqa.employer_enrollment_pdf_v to rl_sam1_ro;

grant select on samqa.employer_enrollment_pdf_v to rl_sam_rw;

grant select on samqa.employer_enrollment_pdf_v to rl_sam_ro;

grant select on samqa.employer_enrollment_pdf_v to sgali;

