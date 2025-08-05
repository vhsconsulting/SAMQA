-- liquibase formatted sql
-- changeset SAMQA:1754373933610 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\vendors_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/vendors_n2.sql:null:56f23289c7d86cf3c73b0e2d47da7bff2c3fe405:create

create index samqa.vendors_n2 on
    samqa.vendors (
        orig_sys_vendor_ref
    );

