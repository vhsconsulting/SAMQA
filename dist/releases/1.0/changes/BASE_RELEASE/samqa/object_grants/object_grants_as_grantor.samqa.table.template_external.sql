-- liquibase formatted sql
-- changeset SAMQA:1754373942305 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.template_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.template_external.sql:null:160f0d852849baf7fff14186c41cadfa9c776e1e:create

grant select on samqa.template_external to rl_sam1_ro;

grant select on samqa.template_external to rl_sam_ro;

