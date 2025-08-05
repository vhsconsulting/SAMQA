-- liquibase formatted sql
-- changeset SAMQA:1754373933610 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\vendors_u1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/vendors_u1.sql:null:fa364d427a5048fe775d8b3cad64c03a0c268fd4:create

create unique index samqa.vendors_u1 on
    samqa.vendors (
        vendor_id
    );

