-- liquibase formatted sql
-- changeset SAMQA:1754373943590 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.emails_one_min_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.emails_one_min_v.sql:null:22b4e741494bf503c4c8c56ae3fe8874caa7b774:create

grant select on samqa.emails_one_min_v to rl_sam1_ro;

grant select on samqa.emails_one_min_v to rl_sam_ro;

grant select on samqa.emails_one_min_v to rl_sam_rw;

