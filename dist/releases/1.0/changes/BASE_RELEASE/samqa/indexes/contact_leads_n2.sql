-- liquibase formatted sql
-- changeset SAMQA:1754373930596 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\contact_leads_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/contact_leads_n2.sql:null:d4b24a64c2d54ab6f95b1f3f073279291ede7a78:create

create index samqa.contact_leads_n2 on
    samqa.contact_leads (
        ref_entity_id,
        ref_entity_type
    );

