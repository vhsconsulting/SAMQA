-- liquibase formatted sql
-- changeset SAMQA:1754373944586 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.monthly_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.monthly_v.sql:null:8493d25b961dee5386fee5582dfe3edc3e417e52:create

grant select on samqa.monthly_v to rl_sam1_ro;

grant select on samqa.monthly_v to rl_sam_rw;

grant select on samqa.monthly_v to rl_sam_ro;

grant select on samqa.monthly_v to sgali;

