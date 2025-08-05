-- liquibase formatted sql
-- changeset SAMQA:1754373926106 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.sequence.cobra_plan_rate_detail_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.sequence.cobra_plan_rate_detail_id_seq.sql:null:6162e7fabbefed8f54ebd1da18d38d2f6a9c3a2f:create

grant alter on newcobra.cobra_plan_rate_detail_id_seq to samqa;

grant select on newcobra.cobra_plan_rate_detail_id_seq to samqa;

