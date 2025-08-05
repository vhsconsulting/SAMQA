-- liquibase formatted sql
-- changeset SAMQA:1754373939448 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.cobra_disbursements.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.cobra_disbursements.sql:null:32a1654453bef3c37ae3a25dad5d91d1f69b7944:create

grant alter on samqa.cobra_disbursements to public;

grant delete on samqa.cobra_disbursements to public;

grant delete on samqa.cobra_disbursements to rl_sam_rw;

grant index on samqa.cobra_disbursements to public;

grant insert on samqa.cobra_disbursements to public;

grant insert on samqa.cobra_disbursements to rl_sam_rw;

grant select on samqa.cobra_disbursements to public;

grant select on samqa.cobra_disbursements to rl_sam1_ro;

grant select on samqa.cobra_disbursements to rl_sam_rw;

grant select on samqa.cobra_disbursements to rl_sam_ro;

grant update on samqa.cobra_disbursements to public;

grant update on samqa.cobra_disbursements to rl_sam_rw;

grant references on samqa.cobra_disbursements to public;

grant read on samqa.cobra_disbursements to public;

grant on commit refresh on samqa.cobra_disbursements to public;

grant query rewrite on samqa.cobra_disbursements to public;

grant debug on samqa.cobra_disbursements to public;

grant flashback on samqa.cobra_disbursements to public;

