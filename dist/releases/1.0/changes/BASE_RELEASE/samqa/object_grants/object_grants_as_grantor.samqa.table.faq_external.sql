-- liquibase formatted sql
-- changeset SAMQA:1754373940427 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.faq_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.faq_external.sql:null:9862e989b14d483b860a1d0e89fc96341c720b44:create

grant select on samqa.faq_external to rl_sam1_ro;

grant select on samqa.faq_external to rl_sam_ro;

