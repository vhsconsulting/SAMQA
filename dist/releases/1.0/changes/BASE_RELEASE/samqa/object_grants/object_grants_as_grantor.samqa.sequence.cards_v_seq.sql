-- liquibase formatted sql
-- changeset SAMQA:1754373937426 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.cards_v_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.cards_v_seq.sql:null:d6d50564d0ea2d5c2c118e1b20eff9dde58c2721:create

grant select on samqa.cards_v_seq to rl_sam_rw;

