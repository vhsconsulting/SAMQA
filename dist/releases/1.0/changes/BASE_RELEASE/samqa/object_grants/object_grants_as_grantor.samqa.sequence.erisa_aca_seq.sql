-- liquibase formatted sql
-- changeset SAMQA:1754373937752 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.erisa_aca_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.erisa_aca_seq.sql:null:a6f03d6ad251120b81709c17e83b8e4b13ab7f80:create

grant select on samqa.erisa_aca_seq to rl_sam_rw;

