-- liquibase formatted sql
-- changeset SAMQA:1754373937386 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.benefit_code_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.benefit_code_seq.sql:null:9874c4ede087b6dbddfed9208aed0504414d0efa:create

grant select on samqa.benefit_code_seq to rl_sam_rw;

