-- liquibase formatted sql
-- changeset SAMQA:1754373937989 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.metavante_card_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.metavante_card_seq.sql:null:29130292328153f99e65da333c8b3041e3130b2e:create

grant select on samqa.metavante_card_seq to rl_sam_rw;

