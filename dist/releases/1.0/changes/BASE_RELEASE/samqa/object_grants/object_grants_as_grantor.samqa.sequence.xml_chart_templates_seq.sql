-- liquibase formatted sql
-- changeset SAMQA:1754373938357 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.xml_chart_templates_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.xml_chart_templates_seq.sql:null:b6c62b588cf818441cd97a4612e40e5a5c4d6e3b:create

grant select on samqa.xml_chart_templates_seq to rl_sam_rw;

