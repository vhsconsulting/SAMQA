-- liquibase formatted sql
-- changeset SAMQA:1754373930555 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\contact_leads_idx5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/contact_leads_idx5.sql:null:f926618061553aa3765a6278a852716fccdd4199:create

create index samqa.contact_leads_idx5 on
    samqa.contact_leads (
        ref_entity_type
    );

