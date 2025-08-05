-- liquibase formatted sql
-- changeset SAMQA:1754373938388 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.account_05192024.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.account_05192024.sql:null:d63e969ba701939dcda1882917d69f115c010452:create

grant select on samqa.account_05192024 to rl_sam_ro;

