create or replace force editionable view samqa.incident_file_attachments_v (
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
    incident_id,
    attached_by,
    attached_on
) as
    select
        nvl(fa.attachment_id, ia.attachment_id)       attachment_id,
        nvl(ia.file_name, fa.document_name)           document_name,
        nvl(ia.attachment, fa.attachment)             attachment,
        fa.entity_id,
        nvl(ia.creation_date, fa.creation_date)       creation_date,
        nvl(ia.created_by, fa.created_by)             created_by,
        nvl(ia.last_update_date, fa.last_update_date) last_update_date,
        pc_incident_notifications.get_user_name_details(lower(nvl(
            get_user_name(nvl(ia.last_updated_by, fa.last_updated_by)),
            pc_users.get_user_name(nvl(ia.last_updated_by, fa.last_updated_by))
        )))                                           last_updated_by,
        fa.document_purpose,
        fa.description,
        ia.incident_id,
        pc_incident_notifications.get_user_name_details(lower(nvl(
            get_user_name(nvl(ia.last_updated_by, fa.last_updated_by)),
            pc_users.get_user_name(nvl(ia.last_updated_by, fa.last_updated_by))
        )))                                           as attached_by,
        ia.creation_date                              as attached_on
    from
        incident_attachments ia,
        file_attachments     fa,
        incident_details     id
    where
            ia.file_attachment_id = fa.attachment_id (+)
        and id.incident_id = ia.incident_id;


-- sqlcl_snapshot {"hash":"b558c4ba19a0dc3afb9f2135392934624ce5e35f","type":"VIEW","name":"INCIDENT_FILE_ATTACHMENTS_V","schemaName":"SAMQA","sxml":""}