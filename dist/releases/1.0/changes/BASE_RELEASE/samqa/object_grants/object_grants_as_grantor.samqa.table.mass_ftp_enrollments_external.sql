-- liquibase formatted sql
-- changeset SAMQA:1754373941096 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.mass_ftp_enrollments_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.mass_ftp_enrollments_external.sql:null:38bdc0e3bcd40e12730748b24117b8aab0f4a1ff:create

grant select on samqa.mass_ftp_enrollments_external to rl_sam1_ro;

grant select on samqa.mass_ftp_enrollments_external to rl_sam_ro;

