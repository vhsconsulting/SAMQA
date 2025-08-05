-- liquibase formatted sql
-- changeset SAMQA:1754373928912 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\ach_transfer_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/ach_transfer_n4.sql:null:9bf4c2443452dc81b779280e968869eec589123d:create

create index samqa.ach_transfer_n4 on
    samqa.ach_transfer (
        invoice_id
    );

