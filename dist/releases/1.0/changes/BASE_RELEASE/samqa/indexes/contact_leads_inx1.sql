-- liquibase formatted sql
-- changeset SAMQA:1754373930573 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\contact_leads_inx1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/contact_leads_inx1.sql:null:62899c01bb9f6f844fec566509125de1db8743f4:create

create index samqa.contact_leads_inx1 on
    samqa.contact_leads (
        contact_id
    );

