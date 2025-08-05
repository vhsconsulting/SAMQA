-- liquibase formatted sql
-- changeset SAMQA:1754373925784 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.clientplanspm.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.clientplanspm.sql:null:1c209ff84271632cb901e3e958cc94eb6a175749:create

grant select on cobrap.clientplanspm to samqa;

