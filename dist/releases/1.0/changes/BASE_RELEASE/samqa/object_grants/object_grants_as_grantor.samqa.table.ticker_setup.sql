-- liquibase formatted sql
-- changeset SAMQA:1754373942335 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ticker_setup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ticker_setup.sql:null:cc5f3dafc5e990aefc6146742ecdcfe528e6f1a7:create

grant delete on samqa.ticker_setup to rl_sam_rw;

grant insert on samqa.ticker_setup to rl_sam_rw;

grant select on samqa.ticker_setup to rl_sam1_ro;

grant select on samqa.ticker_setup to rl_sam_ro;

grant select on samqa.ticker_setup to rl_sam_rw;

grant update on samqa.ticker_setup to rl_sam_rw;

