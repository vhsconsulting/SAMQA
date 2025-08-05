-- liquibase formatted sql
-- changeset SAMQA:1754373930565 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\contact_leads_idx6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/contact_leads_idx6.sql:null:ae87c59cd01e65fc7f0f9dab54540436027fa0e3:create

create index samqa.contact_leads_idx6 on
    samqa.contact_leads (
        send_invoice
    );

