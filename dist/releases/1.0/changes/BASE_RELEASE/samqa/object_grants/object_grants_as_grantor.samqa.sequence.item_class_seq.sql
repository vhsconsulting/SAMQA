-- liquibase formatted sql
-- changeset SAMQA:1754373937889 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.item_class_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.item_class_seq.sql:null:e73a883f8f30b1f7bf342b97cdfa097c211275dc:create

grant select on samqa.item_class_seq to rl_sam_rw;

