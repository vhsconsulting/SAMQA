-- liquibase formatted sql
-- changeset SAMQA:1754373939507 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.cobra_services_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.cobra_services_detail.sql:null:f1f72c65d6de8a9e52c88ad84734c2281c36995a:create

grant select on samqa.cobra_services_detail to qasupport;

grant select on samqa.cobra_services_detail to rl_sam_ro;

grant read on samqa.cobra_services_detail to qasupport;

grant on commit refresh on samqa.cobra_services_detail to qasupport;

grant flashback on samqa.cobra_services_detail to qasupport;

