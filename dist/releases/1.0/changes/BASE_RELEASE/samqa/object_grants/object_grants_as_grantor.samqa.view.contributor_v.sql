-- liquibase formatted sql
-- changeset SAMQA:1754373943427 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.contributor_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.contributor_v.sql:null:7eebd076af6c72b83548e6c67a2074f25e723a38:create

grant select on samqa.contributor_v to rl_sam1_ro;

grant select on samqa.contributor_v to rl_sam_rw;

grant select on samqa.contributor_v to rl_sam_ro;

grant select on samqa.contributor_v to sgali;

