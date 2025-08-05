-- liquibase formatted sql
-- changeset SAMQA:1754373938841 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.bank_serv_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.bank_serv_external.sql:null:72f8d6537496a5034ec132cc285e14535ad40079:create

grant select on samqa.bank_serv_external to rl_sam1_ro;

grant select on samqa.bank_serv_external to rl_sam_ro;

