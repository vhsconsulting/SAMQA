-- liquibase formatted sql
-- changeset SAMQA:1754373945309 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.template_subscrib_hra_wel_letr.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.template_subscrib_hra_wel_letr.sql:null:f72b0ed728be0293cbe6c1e40d0560a14f2fae87:create

grant select on samqa.template_subscrib_hra_wel_letr to rl_sam_ro;

grant select on samqa.template_subscrib_hra_wel_letr to rl_sam_rw;

grant select on samqa.template_subscrib_hra_wel_letr to rl_sam1_ro;

