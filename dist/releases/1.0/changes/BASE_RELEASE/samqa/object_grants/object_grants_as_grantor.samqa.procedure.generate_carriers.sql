-- liquibase formatted sql
-- changeset SAMQA:1754373936871 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.generate_carriers.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.generate_carriers.sql:null:27c94d27556637200a0a286403fd13e414eda351:create

grant execute on samqa.generate_carriers to rl_sam_ro;

