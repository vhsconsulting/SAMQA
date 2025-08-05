-- liquibase formatted sql
-- changeset SAMQA:1754373940960 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.letter_templates.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.letter_templates.sql:null:cde87cf540fc45589974d0df3edc37191208bf3a:create

grant delete on samqa.letter_templates to rl_sam_rw;

grant insert on samqa.letter_templates to rl_sam_rw;

grant select on samqa.letter_templates to rl_sam1_ro;

grant select on samqa.letter_templates to rl_sam_rw;

grant select on samqa.letter_templates to rl_sam_ro;

grant update on samqa.letter_templates to rl_sam_rw;

