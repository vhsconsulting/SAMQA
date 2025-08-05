-- liquibase formatted sql
-- changeset SAMQA:1754373940723 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.hra_deductible_options.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.hra_deductible_options.sql:null:99ae3e651a28d03721ba401a11933515d70ca33c:create

grant delete on samqa.hra_deductible_options to rl_sam_rw;

grant insert on samqa.hra_deductible_options to rl_sam_rw;

grant select on samqa.hra_deductible_options to rl_sam1_ro;

grant select on samqa.hra_deductible_options to rl_sam_rw;

grant select on samqa.hra_deductible_options to rl_sam_ro;

grant update on samqa.hra_deductible_options to rl_sam_rw;

