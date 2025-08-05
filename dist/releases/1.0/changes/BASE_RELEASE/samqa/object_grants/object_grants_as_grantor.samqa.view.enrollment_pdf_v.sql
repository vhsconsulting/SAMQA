-- liquibase formatted sql
-- changeset SAMQA:1754373943771 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.enrollment_pdf_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.enrollment_pdf_v.sql:null:61da43ef0af30a01cfb1feb414d1137818fead07:create

grant select on samqa.enrollment_pdf_v to rl_sam1_ro;

grant select on samqa.enrollment_pdf_v to rl_sam_rw;

grant select on samqa.enrollment_pdf_v to rl_sam_ro;

grant select on samqa.enrollment_pdf_v to sgali;

