-- liquibase formatted sql
-- changeset SAMQA:1754373937684 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.en_type_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.en_type_seq.sql:null:b7f27323ce75bdfd758560b07c06fec5ae0a5f92:create

grant select on samqa.en_type_seq to rl_sam_rw;

