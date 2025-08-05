-- liquibase formatted sql
-- changeset SAMQA:1754373935187 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.dump_csv.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.dump_csv.sql:null:465a995ead29fcea1cc7ede0ab94a1d20bf65eb1:create

grant execute on samqa.dump_csv to rl_sam_rw;

grant execute on samqa.dump_csv to rl_sam1_ro;

grant execute on samqa.dump_csv to rl_sam_ro;

grant debug on samqa.dump_csv to rl_sam_rw;

grant debug on samqa.dump_csv to rl_sam1_ro;

