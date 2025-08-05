-- liquibase formatted sql
-- changeset SAMQA:1754373938037 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.news_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.news_seq.sql:null:854072b4b5e9020a4e955df3248873650665604f:create

grant select on samqa.news_seq to rl_sam_rw;

