-- liquibase formatted sql
-- changeset SAMQA:1754373943023 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.benefit_lookup_code_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.benefit_lookup_code_v.sql:null:14059120a5bc01d790c1abe3b061958ecd56af11:create

grant delete on samqa.benefit_lookup_code_v to public;

grant insert on samqa.benefit_lookup_code_v to public;

grant select on samqa.benefit_lookup_code_v to rl_sam_ro;

grant select on samqa.benefit_lookup_code_v to public;

grant update on samqa.benefit_lookup_code_v to public;

grant references on samqa.benefit_lookup_code_v to public;

grant read on samqa.benefit_lookup_code_v to public;

grant on commit refresh on samqa.benefit_lookup_code_v to public;

grant query rewrite on samqa.benefit_lookup_code_v to public;

grant debug on samqa.benefit_lookup_code_v to public;

grant flashback on samqa.benefit_lookup_code_v to public;

grant merge view on samqa.benefit_lookup_code_v to public;

