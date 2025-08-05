-- liquibase formatted sql
-- changeset SAMQA:1754373938154 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.quote_line_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.quote_line_id_seq.sql:null:abd1755c3e13ceb60d2f4251d0efd3123ac98ea2:create

grant select on samqa.quote_line_id_seq to rl_sam_rw;

