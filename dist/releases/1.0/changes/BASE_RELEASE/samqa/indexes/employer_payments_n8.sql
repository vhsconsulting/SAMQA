-- liquibase formatted sql
-- changeset SAMQA:1754373931209 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\employer_payments_n8.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/employer_payments_n8.sql:null:5a580f4fc33480014892c91364f6c33ead413732:create

create index samqa.employer_payments_n8 on
    samqa.employer_payments (
        invoice_id
    );

