-- liquibase formatted sql
-- changeset SAMQA:1754373940164 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.enterprise.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.enterprise.sql:null:c34db14d73a5ca0ef9478c36dc448a2cadfe9764:create

grant alter on samqa.enterprise to newcobra;

grant alter on samqa.enterprise to public;

grant delete on samqa.enterprise to newcobra;

grant delete on samqa.enterprise to public;

grant delete on samqa.enterprise to rl_sam_rw;

grant index on samqa.enterprise to newcobra;

grant index on samqa.enterprise to public;

grant insert on samqa.enterprise to newcobra;

grant insert on samqa.enterprise to public;

grant insert on samqa.enterprise to rl_sam_rw;

grant insert on samqa.enterprise to cobra;

grant select on samqa.enterprise to rl_sam1_ro;

grant select on samqa.enterprise to newcobra;

grant select on samqa.enterprise to public;

grant select on samqa.enterprise to rl_sam_rw;

grant select on samqa.enterprise to rl_sam_ro;

grant select on samqa.enterprise to cobra;

grant select on samqa.enterprise to reportdb_ro;

grant update on samqa.enterprise to newcobra;

grant update on samqa.enterprise to public;

grant update on samqa.enterprise to rl_sam_rw;

grant references on samqa.enterprise to newcobra;

grant references on samqa.enterprise to public;

grant read on samqa.enterprise to newcobra;

grant read on samqa.enterprise to public;

grant on commit refresh on samqa.enterprise to newcobra;

grant on commit refresh on samqa.enterprise to public;

grant query rewrite on samqa.enterprise to newcobra;

grant query rewrite on samqa.enterprise to public;

grant debug on samqa.enterprise to newcobra;

grant debug on samqa.enterprise to public;

grant flashback on samqa.enterprise to newcobra;

grant flashback on samqa.enterprise to public;

