-- liquibase formatted sql
-- changeset SAMQA:1754373930546 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\contact_leads_idx.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/contact_leads_idx.sql:null:709a0003c09d54e9bf71ba2467704186a77611aa:create

create index samqa.contact_leads_idx on
    samqa.contact_leads (
        ref_entity_id
    );

