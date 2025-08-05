-- liquibase formatted sql
-- changeset SAMQA:1754373937197 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.send_email.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.send_email.sql:null:51bdd473e28cc1b075a8c0b7eb4bc25fd9dca4c9:create

grant execute on samqa.send_email to rl_sam_ro;

