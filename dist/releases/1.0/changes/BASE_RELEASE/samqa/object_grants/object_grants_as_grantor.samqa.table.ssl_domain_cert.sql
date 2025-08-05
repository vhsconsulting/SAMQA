-- liquibase formatted sql
-- changeset SAMQA:1754373942199 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ssl_domain_cert.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ssl_domain_cert.sql:null:106f11bf344283a8570b5f80308edd63715f9a6b:create

grant delete on samqa.ssl_domain_cert to rl_sam_rw;

grant insert on samqa.ssl_domain_cert to rl_sam_rw;

grant select on samqa.ssl_domain_cert to rl_sam1_ro;

grant select on samqa.ssl_domain_cert to rl_sam_rw;

grant select on samqa.ssl_domain_cert to rl_sam_ro;

grant update on samqa.ssl_domain_cert to rl_sam_rw;

