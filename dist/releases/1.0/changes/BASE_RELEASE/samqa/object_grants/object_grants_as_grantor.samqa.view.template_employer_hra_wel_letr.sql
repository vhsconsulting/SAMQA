-- liquibase formatted sql
-- changeset SAMQA:1754373945287 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.template_employer_hra_wel_letr.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.template_employer_hra_wel_letr.sql:null:518997d718e660ef90f3b3c8a2ce670cca2ec592:create

grant select on samqa.template_employer_hra_wel_letr to rl_sam_ro;

grant select on samqa.template_employer_hra_wel_letr to rl_sam_rw;

grant select on samqa.template_employer_hra_wel_letr to rl_sam1_ro;

