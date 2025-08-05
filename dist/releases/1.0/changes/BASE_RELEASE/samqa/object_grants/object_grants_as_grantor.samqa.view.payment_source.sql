-- liquibase formatted sql
-- changeset SAMQA:1754373944850 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.payment_source.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.payment_source.sql:null:5840a1b28b8dba427aa668636fa86e438284f96b:create

grant select on samqa.payment_source to rl_sam1_ro;

grant select on samqa.payment_source to rl_sam_rw;

grant select on samqa.payment_source to rl_sam_ro;

grant select on samqa.payment_source to sgali;

