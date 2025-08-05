-- liquibase formatted sql
-- changeset SAMQA:1754373938230 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.sam_users_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.sam_users_seq.sql:null:c0cc2be2ed58888a2d3c54971c9bc0a5bb0842a9:create

grant select on samqa.sam_users_seq to rl_sam_rw;

