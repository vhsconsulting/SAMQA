create or replace force editionable view samqa.opportunity_file_attachments_v (
    attachment_id,
    document_name,
    attachment,
    entity_id,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    document_purpose,
    description,
    opp_id,
    attached_by,
    attached_on
) as
    select
        attachment_id,
        document_name,
        attachment,
        entity_id,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        document_purpose,
        description,
        opp_id,
        attached_by,
        attached_on
    from
        (
            select
                fa.attachment_id,
                fa.document_name,
                fa.attachment,
                fa.entity_id,
                fa.creation_date,
                fa.created_by,
                fa.last_update_date,
                fa.last_updated_by,
                decode(fa.document_purpose, 'APP', 'Application Form', fa.document_purpose) document_purpose,
                fa.description,
                a.opp_id,
                a.created_by                                                                as attached_by,
                a.created_date                                                              as attached_on
            from
                opportunity_attachments a
                right outer join file_attachments        fa on a.file_attachment_id = fa.attachment_id
            where
                fa.document_purpose = 'APP'
            union all
            select
                fa.attachment_id,
                fa.document_name,
                fa.attachment,
                fa.entity_id,
                fa.creation_date,
                fa.created_by,
                fa.last_update_date,
                fa.last_updated_by,
                fa.document_purpose,
                fa.description,
                a.opp_id,
                a.created_by   as attached_by,
                a.created_date as attached_on
            from
                opportunity_attachments a,
                file_attachments        fa
            where
                a.file_attachment_id = fa.attachment_id
        );


-- sqlcl_snapshot {"hash":"c6a753e8c6322e799cff55d05b479c78d8e2a3c3","type":"VIEW","name":"OPPORTUNITY_FILE_ATTACHMENTS_V","schemaName":"SAMQA","sxml":""}