-- liquibase formatted sql
-- changeset SAMQA:1754373925985 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.cobrap.table.qbpremium.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/cobrap/object_grants/object_grants_as_grantor.cobrap.table.qbpremium.sql:null:65e38e3a502c6842a91bcf4dcc8ba1fe95793a46:create

grant select on cobrap.qbpremium to samqa;

