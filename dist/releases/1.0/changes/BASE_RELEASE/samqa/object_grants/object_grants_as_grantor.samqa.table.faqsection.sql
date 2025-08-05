-- liquibase formatted sql
-- changeset SAMQA:1754373940435 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.faqsection.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.faqsection.sql:null:49d01b8cd66119b543790b30bea4032f678675ac:create

grant delete on samqa.faqsection to rl_sam_rw;

grant insert on samqa.faqsection to rl_sam_rw;

grant select on samqa.faqsection to rl_sam1_ro;

grant select on samqa.faqsection to rl_sam_rw;

grant select on samqa.faqsection to rl_sam_ro;

grant update on samqa.faqsection to rl_sam_rw;

