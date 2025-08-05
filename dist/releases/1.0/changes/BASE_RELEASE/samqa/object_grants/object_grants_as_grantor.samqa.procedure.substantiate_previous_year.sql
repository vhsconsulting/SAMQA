-- liquibase formatted sql
-- changeset SAMQA:1754373937224 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.substantiate_previous_year.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.substantiate_previous_year.sql:null:95a77d87b7eb531b871310b275c5ad2c5cd8b07e:create

grant execute on samqa.substantiate_previous_year to rl_sam_ro;

grant execute on samqa.substantiate_previous_year to rl_sam_rw;

grant execute on samqa.substantiate_previous_year to rl_sam1_ro;

grant debug on samqa.substantiate_previous_year to sgali;

grant debug on samqa.substantiate_previous_year to rl_sam_rw;

grant debug on samqa.substantiate_previous_year to rl_sam1_ro;

