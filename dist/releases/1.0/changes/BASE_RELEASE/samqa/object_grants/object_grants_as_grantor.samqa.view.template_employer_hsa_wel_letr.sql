-- liquibase formatted sql
-- changeset SAMQA:1754373945295 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.template_employer_hsa_wel_letr.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.template_employer_hsa_wel_letr.sql:null:cb526b70eff727ded0584d3b58b8b461d49f77c0:create

grant select on samqa.template_employer_hsa_wel_letr to rl_sam_ro;

grant select on samqa.template_employer_hsa_wel_letr to rl_sam_rw;

grant select on samqa.template_employer_hsa_wel_letr to rl_sam1_ro;

