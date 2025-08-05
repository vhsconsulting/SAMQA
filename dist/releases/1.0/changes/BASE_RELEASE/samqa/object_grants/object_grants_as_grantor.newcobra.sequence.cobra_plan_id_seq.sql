-- liquibase formatted sql
-- changeset SAMQA:1754373926101 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.sequence.cobra_plan_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.sequence.cobra_plan_id_seq.sql:null:2ee85bad5c692556a8ad6189968c0a5aa815f89a:create

grant alter on newcobra.cobra_plan_id_seq to samqa;

grant select on newcobra.cobra_plan_id_seq to samqa;

