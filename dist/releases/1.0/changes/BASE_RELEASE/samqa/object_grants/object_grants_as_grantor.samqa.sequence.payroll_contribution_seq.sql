-- liquibase formatted sql
-- changeset SAMQA:1754373938119 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.payroll_contribution_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.payroll_contribution_seq.sql:null:e90be3d2b8a5ac83d026d90639b6c3e4d5d6d1d3:create

grant select on samqa.payroll_contribution_seq to rl_sam_rw;

