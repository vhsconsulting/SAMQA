-- liquibase formatted sql
-- changeset SAMQA:1754373939984 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.employer_online_product_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.employer_online_product_staging.sql:null:62f1b42df5d724c4d22aad5501d09412a05479bc:create

grant delete on samqa.employer_online_product_staging to rl_sam_rw;

grant insert on samqa.employer_online_product_staging to rl_sam_rw;

grant select on samqa.employer_online_product_staging to rl_sam1_ro;

grant select on samqa.employer_online_product_staging to rl_sam_ro;

grant select on samqa.employer_online_product_staging to rl_sam_rw;

grant update on samqa.employer_online_product_staging to rl_sam_rw;

