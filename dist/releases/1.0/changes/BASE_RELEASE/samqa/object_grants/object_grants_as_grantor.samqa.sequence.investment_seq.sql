-- liquibase formatted sql
-- changeset SAMQA:1754373937849 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.investment_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.investment_seq.sql:null:f521c78a0ec27ba8c6afc95c7902c1f55a2d70d5:create

grant select on samqa.investment_seq to rl_sam_rw;

