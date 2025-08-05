-- liquibase formatted sql
-- changeset SAMQA:1754373939363 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.claim_upload_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.claim_upload_external.sql:null:b15bdbb01872fbb75a3fc7d9c937bdea5937a263:create

grant select on samqa.claim_upload_external to rl_sam1_ro;

grant select on samqa.claim_upload_external to rl_sam_ro;

