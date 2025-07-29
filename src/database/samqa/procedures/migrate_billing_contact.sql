create or replace procedure samqa.migrate_billing_contact as

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
            replace(b.entrp_code, '-') entrp_code,
            b.entrp_contact,
            b.name,
            c.start_date,
            a.invoice_email,
            c.account_type
        from
            invoice_parameters a,
            enterprise         b,
            account            c
        where
                a.entity_id = b.entrp_id
            and a.entity_type = 'EMPLOYER'
            and c.entrp_id = b.entrp_id
            and c.account_type in ( 'HRA', 'FSA' )
            and instr(a.invoice_email, ',') > 0
            and b.entrp_code is not null
    ) loop
        for xx in (
            select
                column_value
            from
                table ( str2tbl(x.invoice_email) )
            where
                not exists (
                    select
                        *
                    from
                        contact
                    where
                            entity_id = x.entrp_code
                        and entity_type = 'ENTERPRISE'
                        and lower(email) = lower(column_value)
                )
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
                       x.entrp_code,
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
                       null,
                       xx.column_value,
                       null,
                       'Migrating from Employer Contact',
                       sysdate,
                       0,
                       sysdate,
                       0,
                       'FEE_BILLING',
                       x.account_type );

        end loop;
    end loop;
end;
/


-- sqlcl_snapshot {"hash":"e0dcb9d99cc66b7407ad99fb466d4ac55d3275f4","type":"PROCEDURE","name":"MIGRATE_BILLING_CONTACT","schemaName":"SAMQA","sxml":""}