-- liquibase formatted sql
-- changeset SAMQA:1754373938154 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.quote_header_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.quote_header_id_seq.sql:null:59db3759b849b692cc8dbaf45046515bd29235e5:create

grant select on samqa.quote_header_id_seq to rl_sam_rw;

