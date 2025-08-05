-- liquibase formatted sql
-- changeset SAMQA:1754373944778 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.outputto_collection.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.outputto_collection.sql:null:10f08a474b7abf70a9370ede94d0cd0df1e4226a:create

grant select on samqa.outputto_collection to rl_sam1_ro;

grant select on samqa.outputto_collection to rl_sam_ro;

grant select on samqa.outputto_collection to rl_sam_rw;

