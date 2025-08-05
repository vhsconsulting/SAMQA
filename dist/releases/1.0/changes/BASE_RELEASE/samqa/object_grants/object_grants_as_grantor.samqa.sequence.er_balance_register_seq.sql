-- liquibase formatted sql
-- changeset SAMQA:1754373937745 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.er_balance_register_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.er_balance_register_seq.sql:null:d3d4d61f11756714970d59d8258d5b644f62f068:create

grant select on samqa.er_balance_register_seq to rl_sam_rw;

