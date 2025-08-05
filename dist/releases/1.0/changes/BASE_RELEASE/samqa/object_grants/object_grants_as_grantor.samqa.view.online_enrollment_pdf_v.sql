-- liquibase formatted sql
-- changeset SAMQA:1754373944757 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.online_enrollment_pdf_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.online_enrollment_pdf_v.sql:null:2c11425c4277d21359fa97333ff0102021927a26:create

grant select on samqa.online_enrollment_pdf_v to rl_sam1_ro;

grant select on samqa.online_enrollment_pdf_v to rl_sam_rw;

grant select on samqa.online_enrollment_pdf_v to rl_sam_ro;

grant select on samqa.online_enrollment_pdf_v to sgali;

