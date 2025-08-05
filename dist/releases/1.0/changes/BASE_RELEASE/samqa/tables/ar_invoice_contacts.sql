-- liquibase formatted sql
-- changeset SAMQA:1754374151648 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ar_invoice_contacts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ar_invoice_contacts.sql:null:66ab6f5b394a0bdaf6e01717eab61118b7f66f46:create

create table samqa.ar_invoice_contacts (
    invoice_id    number,
    contact_id    number,
    creation_date date,
    created_by    number,
    start_date    date,
    end_date      date,
    rate_plan_id  number
);

