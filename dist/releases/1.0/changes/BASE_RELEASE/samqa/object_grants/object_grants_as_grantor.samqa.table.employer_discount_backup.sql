-- liquibase formatted sql
-- changeset SAMQA:1754373939912 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.employer_discount_backup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.employer_discount_backup.sql:null:e30dcf0ab80b16610719c350e1828f264869e5a5:create

grant delete on samqa.employer_discount_backup to rl_sam_rw;

grant insert on samqa.employer_discount_backup to rl_sam_rw;

grant select on samqa.employer_discount_backup to rl_sam1_ro;

grant select on samqa.employer_discount_backup to rl_sam_ro;

grant select on samqa.employer_discount_backup to rl_sam_rw;

grant update on samqa.employer_discount_backup to rl_sam_rw;

