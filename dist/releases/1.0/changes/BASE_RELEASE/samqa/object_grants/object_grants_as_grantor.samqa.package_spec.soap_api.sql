-- liquibase formatted sql
-- changeset SAMQA:1754373936619 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.soap_api.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.soap_api.sql:null:902dd5d004cdecfa95d7e13b751acc4d6bd8d93c:create

grant execute on samqa.soap_api to rl_sam_ro;

grant execute on samqa.soap_api to rl_sam_rw;

grant execute on samqa.soap_api to rl_sam1_ro;

grant debug on samqa.soap_api to sgali;

grant debug on samqa.soap_api to rl_sam_rw;

grant debug on samqa.soap_api to rl_sam1_ro;

grant debug on samqa.soap_api to rl_sam_ro;

