-- liquibase formatted sql
-- changeset SAMQA:1754374179953 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\toolkit_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/toolkit_v.sql:null:d119d5fc3acface2f5781d5b86686c5f0fbaf9d0:create

create or replace force editionable view samqa.toolkit_v (
    form_id,
    url,
    form_name,
    section_type,
    product_type
) as
    select
        form_id,
        file_name url,
        form_name,
        section_type,
        product_type
    from
        website_forms
    where
            company_name = 'SHA'
        and category = 'TOOLKIT';

