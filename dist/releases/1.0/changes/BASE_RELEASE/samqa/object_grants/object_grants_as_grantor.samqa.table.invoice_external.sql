-- liquibase formatted sql
-- changeset SAMQA:1754373940865 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.invoice_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.invoice_external.sql:null:825de4b3a821f69de47fb82d2526e1ab3f65cac1:create

grant select on samqa.invoice_external to rl_sam1_ro;

grant select on samqa.invoice_external to rl_sam_ro;

