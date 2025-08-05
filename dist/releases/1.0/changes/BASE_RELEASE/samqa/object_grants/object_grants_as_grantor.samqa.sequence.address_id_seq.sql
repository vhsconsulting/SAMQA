-- liquibase formatted sql
-- changeset SAMQA:1754373937319 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.address_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.address_id_seq.sql:null:35769ebf68f0d813013b7545967b9ad32c5965ac:create

grant select on samqa.address_id_seq to rl_sam_rw;

