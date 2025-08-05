-- liquibase formatted sql
-- changeset SAMQA:1754373944301 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.hra_renewal_analysis_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.hra_renewal_analysis_v.sql:null:8642c6cf613d4520a6c42d24abce0d00dddfa2e6:create

grant select on samqa.hra_renewal_analysis_v to rl_sam1_ro;

grant select on samqa.hra_renewal_analysis_v to rl_sam_rw;

grant select on samqa.hra_renewal_analysis_v to rl_sam_ro;

grant select on samqa.hra_renewal_analysis_v to sgali;

