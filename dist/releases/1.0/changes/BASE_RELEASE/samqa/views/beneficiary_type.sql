-- liquibase formatted sql
-- changeset SAMQA:1754374168689 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\beneficiary_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/beneficiary_type.sql:null:ffb2cf35f911a4930d59c79902457800686fc013:create

create or replace force editionable view samqa.beneficiary_type (
    ben_type_code,
    ben_type
) as
    select
        lookup_code ben_type_code,
        meaning     ben_type
    from
        lookups
    where
        lookup_name = 'BENEFICIARY_TYPE';

