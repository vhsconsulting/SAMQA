-- liquibase formatted sql
-- changeset SAMQA:1754373943584 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.email_blast_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.email_blast_v.sql:null:ff686838cd0441781ff56f55144274353af9deb7:create

grant select on samqa.email_blast_v to rl_sam1_ro;

grant select on samqa.email_blast_v to rl_sam_rw;

grant select on samqa.email_blast_v to rl_sam_ro;

grant select on samqa.email_blast_v to sgali;

