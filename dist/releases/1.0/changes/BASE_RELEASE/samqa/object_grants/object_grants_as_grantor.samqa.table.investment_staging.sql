-- liquibase formatted sql
-- changeset SAMQA:1754373940849 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.investment_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.investment_staging.sql:null:a68e82aa2a67364c77f2c53e6aefbed928ed2eab:create

grant delete on samqa.investment_staging to rl_sam_rw;

grant insert on samqa.investment_staging to rl_sam_rw;

grant select on samqa.investment_staging to rl_sam1_ro;

grant select on samqa.investment_staging to rl_sam_ro;

grant select on samqa.investment_staging to rl_sam_rw;

grant update on samqa.investment_staging to rl_sam_rw;

