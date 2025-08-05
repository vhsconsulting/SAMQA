-- liquibase formatted sql
-- changeset SAMQA:1754373937507 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.cobra_interface_error_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.cobra_interface_error_seq.sql:null:18a9441fca12bfe531869c4c218670875aa29937:create

grant select on samqa.cobra_interface_error_seq to rl_sam_rw;

