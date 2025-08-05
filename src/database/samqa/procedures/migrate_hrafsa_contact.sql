create or replace procedure samqa.migrate_hrafsa_contact (
    p_tax_id in varchar2
) as

    x_contact_id    number;
    x_user_id       number;
    x_return_status varchar2(3200);
    x_error_message varchar2(3200);
    p_role_entries  pc_online_enrollment.varchar2_tbl;
    l_count         number := 0;
    l_enroll_count  number := 0;
begin
    for x in (
        select
            a.entrp_id,
            a.entrp_phones,
            a.entrp_email,
            a.entrp_contact,
            c.start_date,
            regexp_count(a.entrp_contact, ' '),
            c.account_type
        from
            enterprise a,
            account    c
        where
            a.entrp_contact is not null
            and a.entrp_id = c.entrp_id
            and c.account_type in ( 'HRA', 'FSA' )
            and regexp_count(a.entrp_contact, ' ') >= 1
    ) loop
        insert into contact (
            contact_id,
            entity_id,
            entity_type,
            title,
            first_name,
            last_name,
            middle_name,
            gender,
            status,
            start_date,
            end_date,
            phone,
            email,
            fax,
            note,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            contact_type,
            account_type
        ) values ( contact_seq.nextval,
                   x.entrp_id,
                   'ENTERPRISE',
                   null,
                   substr(x.entrp_contact,
                          1,
                          instr(x.entrp_contact, ' ')),
                   substr(x.entrp_contact,
                          instr(x.entrp_contact, ' ') + 1,
                          length(x.entrp_contact)),
                   null,
                   null,
                   'A',
                   x.start_date,
                   null,
                   x.entrp_phones,
                   x.entrp_email,
                   null,
                   'Migrating from Employer Contact',
                   sysdate,
                   0,
                   sysdate,
                   0,
                   'MAIN',
                   x.account_type );

    end loop;
end;
/


-- sqlcl_snapshot {"hash":"11b4168d8c6e326e2fe6b1f785af8275ef2148b3","type":"PROCEDURE","name":"MIGRATE_HRAFSA_CONTACT","schemaName":"SAMQA","sxml":""}