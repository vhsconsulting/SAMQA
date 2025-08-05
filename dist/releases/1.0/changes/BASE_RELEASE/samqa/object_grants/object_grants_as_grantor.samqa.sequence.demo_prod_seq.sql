-- liquibase formatted sql
-- changeset SAMQA:1754373937622 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.demo_prod_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.demo_prod_seq.sql:null:95c9c6af2d747488469c105f8982ff9c9ecd67eb:create

grant select on samqa.demo_prod_seq to rl_sam_rw;

