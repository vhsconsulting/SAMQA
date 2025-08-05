-- liquibase formatted sql
-- changeset SAMQA:1754374176164 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\id_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/id_type.sql:null:1afda307b93320c55947659c29a82c2aca80b678:create

create or replace force editionable view samqa.id_type (
    id_type,
    id_type_name
) as
    select
        lookup_code id_type,
        meaning     id_type_name
    from
        lookups
    where
        lookup_name = 'ID_TYPE';

