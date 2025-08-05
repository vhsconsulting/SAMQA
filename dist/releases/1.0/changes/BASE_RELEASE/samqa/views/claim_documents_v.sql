-- liquibase formatted sql
-- changeset SAMQA:1754374169844 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\claim_documents_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/claim_documents_v.sql:null:09d21cbb89d430fc920e20d02d010978945d8b37:create

create or replace force editionable view samqa.claim_documents_v (
    claim_id,
    document_name,
    attachment,
    uploaded_date
) as
    select
        entity_id                            claim_id,
        document_name,
        attachment,
        to_char(creation_date, 'mm/dd/yyyy') uploaded_date
    from
        file_attachments a
    where
        entity_name = 'CLAIMN';

