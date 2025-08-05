-- liquibase formatted sql
-- changeset SAMQA:1754373938154 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.profession_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.profession_seq.sql:null:13625e611539bf194130dcb85aa05b9bb72ed2b8:create

grant select on samqa.profession_seq to rl_sam_rw;

