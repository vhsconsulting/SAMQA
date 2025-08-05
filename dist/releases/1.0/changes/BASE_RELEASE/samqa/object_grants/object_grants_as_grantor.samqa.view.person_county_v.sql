-- liquibase formatted sql
-- changeset SAMQA:1754373944891 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.person_county_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.person_county_v.sql:null:5727d06648241deb5cd226abf21bc0a933dad514:create

grant select on samqa.person_county_v to rl_sam1_ro;

grant select on samqa.person_county_v to rl_sam_rw;

grant select on samqa.person_county_v to rl_sam_ro;

grant select on samqa.person_county_v to sgali;

