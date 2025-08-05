-- liquibase formatted sql
-- changeset SAMQA:1754374176498 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\insurance_category.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/insurance_category.sql:null:beecaaf81cde5a117d78e36ae77fd671a1351af7:create

create or replace force editionable view samqa.insurance_category (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'INSURANCE_CATEGORY';

