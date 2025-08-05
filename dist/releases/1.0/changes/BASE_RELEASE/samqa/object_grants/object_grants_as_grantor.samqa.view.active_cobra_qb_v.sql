-- liquibase formatted sql
-- changeset SAMQA:1754373942848 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.active_cobra_qb_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.active_cobra_qb_v.sql:null:6db303b4069e132431ed72202744c3a67a2088c7:create

grant delete on samqa.active_cobra_qb_v to public;

grant insert on samqa.active_cobra_qb_v to public;

grant select on samqa.active_cobra_qb_v to public;

grant select on samqa.active_cobra_qb_v to rl_sam1_ro;

grant select on samqa.active_cobra_qb_v to rl_sam_ro;

grant select on samqa.active_cobra_qb_v to rl_sam_rw;

grant update on samqa.active_cobra_qb_v to public;

grant references on samqa.active_cobra_qb_v to public;

grant read on samqa.active_cobra_qb_v to public;

grant on commit refresh on samqa.active_cobra_qb_v to public;

grant query rewrite on samqa.active_cobra_qb_v to public;

grant debug on samqa.active_cobra_qb_v to public;

grant flashback on samqa.active_cobra_qb_v to public;

grant merge view on samqa.active_cobra_qb_v to public;

