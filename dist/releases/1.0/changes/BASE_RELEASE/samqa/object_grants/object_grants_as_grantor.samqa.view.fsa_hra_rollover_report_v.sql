-- liquibase formatted sql
-- changeset SAMQA:1754373944092 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_hra_rollover_report_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_hra_rollover_report_v.sql:null:3e1249db778dfcdd62b89aeb8dfe9b5660205ebe:create

grant select on samqa.fsa_hra_rollover_report_v to rl_sam1_ro;

grant select on samqa.fsa_hra_rollover_report_v to rl_sam_rw;

grant select on samqa.fsa_hra_rollover_report_v to rl_sam_ro;

grant select on samqa.fsa_hra_rollover_report_v to sgali;

