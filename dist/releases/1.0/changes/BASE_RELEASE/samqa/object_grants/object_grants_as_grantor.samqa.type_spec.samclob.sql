-- liquibase formatted sql
-- changeset SAMQA:1754373942616 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.type_spec.samclob.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.type_spec.samclob.sql:null:7d9cc424c418c5d82fe4780205fa7ab9011f23fe:create

grant execute on samqa.samclob to rl_sam1_ro;

grant execute on samqa.samclob to rl_sam_ro;

grant execute on samqa.samclob to rl_sam_rw;

