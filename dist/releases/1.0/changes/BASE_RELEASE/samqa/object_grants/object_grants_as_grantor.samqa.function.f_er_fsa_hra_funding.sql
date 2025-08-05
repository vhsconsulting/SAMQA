-- liquibase formatted sql
-- changeset SAMQA:1754373935199 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.f_er_fsa_hra_funding.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.f_er_fsa_hra_funding.sql:null:cc9c6bb5305e290a3e93dcd42de33338f2a745a5:create

grant execute on samqa.f_er_fsa_hra_funding to rl_sam_ro;

