-- liquibase formatted sql
-- changeset SAMQA:1754373937502 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.cobra_disbursements_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.cobra_disbursements_seq.sql:null:f339a80de68ae49ba24cc85d73706f0f86709185:create

grant select on samqa.cobra_disbursements_seq to rl_sam_rw;

