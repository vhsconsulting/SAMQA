-- liquibase formatted sql
-- changeset SAMQA:1754373940976 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.letters.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.letters.sql:null:1ac24c2381d94dc4995ae8a198a14dfbe816a575:create

grant delete on samqa.letters to rl_sam_rw;

grant insert on samqa.letters to rl_sam_rw;

grant select on samqa.letters to rl_sam1_ro;

grant select on samqa.letters to rl_sam_rw;

grant select on samqa.letters to rl_sam_ro;

grant update on samqa.letters to rl_sam_rw;

