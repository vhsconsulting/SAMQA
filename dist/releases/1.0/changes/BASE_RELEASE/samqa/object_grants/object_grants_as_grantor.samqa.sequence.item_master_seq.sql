-- liquibase formatted sql
-- changeset SAMQA:1754373937897 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.item_master_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.item_master_seq.sql:null:dee5def9c5a120e41245274f61384f99fbdba927:create

grant select on samqa.item_master_seq to rl_sam_rw;

