-- liquibase formatted sql
-- changeset SAMQA:1754373937789 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.fee_names_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.fee_names_seq.sql:null:a8f374d2851812da76530bde9afae14473ab9c40:create

grant select on samqa.fee_names_seq to rl_sam_rw;

