-- liquibase formatted sql
-- changeset SAMQA:1754373945324 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.template_subscrib_hsa_wel_letr.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.template_subscrib_hsa_wel_letr.sql:null:1dbc7503c66e271ed80bb12c93174a422b0b68f0:create

grant select on samqa.template_subscrib_hsa_wel_letr to rl_sam_ro;

grant select on samqa.template_subscrib_hsa_wel_letr to rl_sam_rw;

grant select on samqa.template_subscrib_hsa_wel_letr to rl_sam1_ro;

