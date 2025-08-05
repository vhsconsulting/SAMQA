-- liquibase formatted sql
-- changeset SAMQA:1754373939857 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.emp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.emp.sql:null:604a15519b04f83a420aeea7b3738486aa594edc:create

grant select on samqa.emp to rl_sam_ro;

