-- liquibase formatted sql
-- changeset SAMQA:1754373937960 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.mass_enrollments_error_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.mass_enrollments_error_seq.sql:null:15a4d8767d55588b3caabe145f32580ef15d89dc:create

grant select on samqa.mass_enrollments_error_seq to rl_sam_rw;

