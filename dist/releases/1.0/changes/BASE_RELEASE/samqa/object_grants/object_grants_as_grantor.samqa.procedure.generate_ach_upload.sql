-- liquibase formatted sql
-- changeset SAMQA:1754373936867 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.generate_ach_upload.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.generate_ach_upload.sql:null:6bc445d3a2b99a2e0583bc09ce84a5a88543f8e0:create

grant execute on samqa.generate_ach_upload to rl_sam_ro;

