-- liquibase formatted sql
-- changeset SAMQA:1754373936963 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.migrate_hrafsa_contact.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.migrate_hrafsa_contact.sql:null:7096f965b476586afa3effafced11ff3a730daf9:create

grant execute on samqa.migrate_hrafsa_contact to rl_sam_ro;

grant execute on samqa.migrate_hrafsa_contact to rl_sam_rw;

grant execute on samqa.migrate_hrafsa_contact to rl_sam1_ro;

grant debug on samqa.migrate_hrafsa_contact to sgali;

grant debug on samqa.migrate_hrafsa_contact to rl_sam_rw;

grant debug on samqa.migrate_hrafsa_contact to rl_sam1_ro;

