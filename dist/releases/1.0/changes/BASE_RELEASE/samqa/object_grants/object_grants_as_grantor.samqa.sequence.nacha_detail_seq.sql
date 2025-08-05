-- liquibase formatted sql
-- changeset SAMQA:1754373938008 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.nacha_detail_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.nacha_detail_seq.sql:null:1e9187817c54f3a6a3d8f3c2c3fb8db86067c96e:create

grant select on samqa.nacha_detail_seq to rl_sam_rw;

