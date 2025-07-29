create or replace procedure samqa.migrate_claim_contact as
begin
    for x in (
        select
            b.tax_id,
            a.account_type,
            b.contact_email
        from
            account        a,
            contact_import b
        where
                a.acc_num = b.acc_num
            and b.contact_email like '%<%'
    ) loop
        for xx in (
            select
                trim(column_value) column_value
            from
                table ( in_list(x.contact_email, ';') )
            where
                not exists (
                    select
                        *
                    from
                        contact
                    where
                            entity_id = replace(
                                replace(x.tax_id, '-', ''),
                                ' ',
                                ''
                            )
                        and entity_type = 'ENTERPRISE'
                        and contact_type in ( 'PRIMARY', 'CLAIM_BILLING' )
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
                       replace(x.tax_id, '-'),
                       'ENTERPRISE',
                       null,
                       replace(xx.column_value,
                               1,
                               instr(xx.column_value, '<') - 1),
                       null,
                       null,
                       null,
                       'A',
                       sysdate,
                       null,
                       null,
                       replace(
                           substr(xx.column_value,
                                  instr(xx.column_value, '<') + 1,
                                  instr(xx.column_value, '>')),
                           '>'
                       ),
                       null,
                       'Migrating from Finance List',
                       sysdate,
                       0,
                       sysdate,
                       0,
                       'CLAIM_BILLING',
                       x.account_type );

        end loop;
    end loop;
end;
/


-- sqlcl_snapshot {"hash":"6c2a3532ad78d0c36c4f9ba11103a291ee87797d","type":"PROCEDURE","name":"MIGRATE_CLAIM_CONTACT","schemaName":"SAMQA","sxml":""}