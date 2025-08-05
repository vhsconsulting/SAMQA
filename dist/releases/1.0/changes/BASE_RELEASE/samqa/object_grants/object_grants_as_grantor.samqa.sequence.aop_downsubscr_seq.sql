-- liquibase formatted sql
-- changeset SAMQA:1754373937325 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.aop_downsubscr_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.aop_downsubscr_seq.sql:null:52c4d28c1ecb3f0eb2c8e8860171fdeb92921397:create

grant select on samqa.aop_downsubscr_seq to rl_sam_rw;

