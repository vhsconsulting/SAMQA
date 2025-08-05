-- liquibase formatted sql
-- changeset SAMQA:1754373938969 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.beneficiary_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.beneficiary_external.sql:null:28bb30bb6c4393df0176ce1a3481be335625e585:create

grant select on samqa.beneficiary_external to rl_sam1_ro;

grant select on samqa.beneficiary_external to rl_sam_ro;

