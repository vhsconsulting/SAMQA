-- liquibase formatted sql
-- changeset SAMQA:1754373943475 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.custom_rates_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.custom_rates_v.sql:null:0d9b9b7c8e0392eb2880d03435a03a340e247bd4:create

grant select on samqa.custom_rates_v to rl_sam1_ro;

grant select on samqa.custom_rates_v to rl_sam_rw;

grant select on samqa.custom_rates_v to rl_sam_ro;

grant select on samqa.custom_rates_v to sgali;

