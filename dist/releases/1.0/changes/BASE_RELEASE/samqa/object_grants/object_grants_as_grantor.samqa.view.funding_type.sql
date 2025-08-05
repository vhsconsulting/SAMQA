-- liquibase formatted sql
-- changeset SAMQA:1754373944198 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.funding_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.funding_type.sql:null:7c29614b64de43e3416071d876441f042a91c6dd:create

grant select on samqa.funding_type to rl_sam1_ro;

grant select on samqa.funding_type to rl_sam_rw;

grant select on samqa.funding_type to rl_sam_ro;

grant select on samqa.funding_type to sgali;

