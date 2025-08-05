-- liquibase formatted sql
-- changeset SAMQA:1754373940748 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.hsa_individual_enrollments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.hsa_individual_enrollments.sql:null:17f138c54958df082e1d4060d5d4c2dfbc715515:create

grant delete on samqa.hsa_individual_enrollments to rl_sam_rw;

grant insert on samqa.hsa_individual_enrollments to rl_sam_rw;

grant select on samqa.hsa_individual_enrollments to rl_sam1_ro;

grant select on samqa.hsa_individual_enrollments to rl_sam_ro;

grant select on samqa.hsa_individual_enrollments to rl_sam_rw;

grant update on samqa.hsa_individual_enrollments to rl_sam_rw;

