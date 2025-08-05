-- liquibase formatted sql
-- changeset SAMQA:1754373940440 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.faqsection_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.faqsection_external.sql:null:288fe96b71a15859eb15209dca28af139a804518:create

grant select on samqa.faqsection_external to rl_sam1_ro;

grant select on samqa.faqsection_external to rl_sam_ro;

