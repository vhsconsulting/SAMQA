-- liquibase formatted sql
-- changeset SAMQA:1754373937889 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.irs_amendment_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.irs_amendment_seq.sql:null:de1bc2a4cb91b48d68375ba57a25351bf9a842d3:create

grant select on samqa.irs_amendment_seq to rl_sam_rw;

