-- liquibase formatted sql
-- changeset SAMQA:1754373944992 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.processed_fsa_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.processed_fsa_claims_v.sql:null:0ca9154e4f3cc06cad2183883da21a4ef5de1828:create

grant select on samqa.processed_fsa_claims_v to rl_sam1_ro;

grant select on samqa.processed_fsa_claims_v to rl_sam_rw;

grant select on samqa.processed_fsa_claims_v to rl_sam_ro;

grant select on samqa.processed_fsa_claims_v to sgali;

