-- liquibase formatted sql
-- changeset SAMQA:1754373938049 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.notif_template_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.notif_template_seq.sql:null:9d5636a24998ea00fadfcb077ef5f75d67143800:create

grant select on samqa.notif_template_seq to rl_sam_rw;

