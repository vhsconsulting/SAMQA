-- liquibase formatted sql
-- changeset SAMQA:1754373935764 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.gen_xl_xml.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.gen_xl_xml.sql:null:986996062f44293b9df854ff0c9ec0443864aacc:create

grant execute on samqa.gen_xl_xml to rl_sam_ro;

grant execute on samqa.gen_xl_xml to rl_sam_rw;

grant execute on samqa.gen_xl_xml to rl_sam1_ro;

grant debug on samqa.gen_xl_xml to rl_sam_ro;

grant debug on samqa.gen_xl_xml to sgali;

grant debug on samqa.gen_xl_xml to rl_sam_rw;

grant debug on samqa.gen_xl_xml to rl_sam1_ro;

