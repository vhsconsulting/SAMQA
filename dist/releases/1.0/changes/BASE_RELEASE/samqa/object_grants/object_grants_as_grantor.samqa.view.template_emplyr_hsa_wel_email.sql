-- liquibase formatted sql
-- changeset SAMQA:1754373945301 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.template_emplyr_hsa_wel_email.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.template_emplyr_hsa_wel_email.sql:null:0864da412f4fbe9af7b916be826e7b3709f9e002:create

grant select on samqa.template_emplyr_hsa_wel_email to rl_sam_ro;

grant select on samqa.template_emplyr_hsa_wel_email to rl_sam_rw;

grant select on samqa.template_emplyr_hsa_wel_email to rl_sam1_ro;

