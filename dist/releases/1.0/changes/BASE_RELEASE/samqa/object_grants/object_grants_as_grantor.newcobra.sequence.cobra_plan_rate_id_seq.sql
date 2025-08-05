-- liquibase formatted sql
-- changeset SAMQA:1754373926111 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.newcobra.sequence.cobra_plan_rate_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/newcobra/object_grants/object_grants_as_grantor.newcobra.sequence.cobra_plan_rate_id_seq.sql:null:8d63b8cfe02402961c048387070a3ae7573ee0c9:create

grant alter on newcobra.cobra_plan_rate_id_seq to samqa;

grant select on newcobra.cobra_plan_rate_id_seq to samqa;

