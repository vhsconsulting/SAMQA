-- liquibase formatted sql
-- changeset SAMQA:1754373936947 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.migrate_contact.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.migrate_contact.sql:null:a406a0591e66961bdf720bdaf50123edac8a14ac:create

grant execute on samqa.migrate_contact to rl_sam_ro;

