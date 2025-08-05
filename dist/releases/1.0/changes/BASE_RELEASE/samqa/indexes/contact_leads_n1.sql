-- liquibase formatted sql
-- changeset SAMQA:1754373930582 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\contact_leads_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/contact_leads_n1.sql:null:8f881795d82f9351d1d5bfa4736b3710d874bafd:create

create index samqa.contact_leads_n1 on
    samqa.contact_leads (
        entity_id
    );

