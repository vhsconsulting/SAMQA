create or replace procedure samqa.contact_role_migration as
begin
    for x in (
        select
            lower(email) email,
            replace(
                replace(entity_id, '-'),
                ' '
            )            entity_id
        from
            contact
        where
            email is not null
            and entity_type = 'ENTERPRISE'
        group by
            lower(email),
            replace(
                replace(entity_id, '-'),
                ' '
            )
        having
            count(*) >= 1
    ) loop
        for xx in (
            select
                contact_id
            from
                contact
            where
                    lower(email) = x.email
                and rownum = 1
        ) loop
            for xxx in (
                select
                    contact_id,
                    contact_type,
                    created_by,
                    status,
                    start_date
                from
                    contact
                where
                        lower(email) = x.email
                    and contact_type is not null
            ) loop
                insert into contact_role (
                    contact_role_id,
                    contact_id,
                    role_type,
                    description,
                    effective_date,
                    effective_end_date,
                    created_by,
                    last_updated_by,
                    ref_contact_id
                ) values ( contact_role_seq.nextval,
                           xx.contact_id,
                           xxx.contact_type,
                           xxx.contact_type,
                           xxx.start_date,
                           case
                               when xxx.status = 'I' then
                                   sysdate
                               else
                                   null
                           end,
                           xxx.created_by,
                           xxx.created_by,
                           xxx.contact_id );

            end loop;
        end loop;
    end loop;

    for x in (
        select
            lower(email) email,
            replace(
                replace(entity_id, '-'),
                ' '
            )            entity_id
        from
            contact
        where
            user_id is not null
    ) loop
        for xx in (
            select
                contact_id,
                user_id,
                created_by
            from
                contact
            where
                    lower(email) = x.email
                and user_id is not null
        ) loop
            insert into contact_user_map (
                contact_user_id,
                contact_id,
                user_id,
                created_by,
                last_updated_by
            ) values ( contact_user_map_seq.nextval,
                       xx.contact_id,
                       xx.user_id,
                       xx.created_by,
                       xx.created_by );

        end loop;
    end loop;

    for x in (
        select
            lower(email) email,
            entity_type,
            replace(
                replace(entity_id, '-'),
                ' '
            )            entity_id,
            cobra_id_number,
            a.start_date,
            contact_id
        from
            contact a
        where
            entity_type in ( 'CLIENTDIVISIONCONTACT', 'CLIENTCONTACT' )
            and exists (
                select
                    *
                from
                    contact b
                where
                        replace(
                            replace(b.entity_id, '-'),
                            ' '
                        ) = a.entity_id
                    and entity_type = 'ENTERPRISE'
                    and a.email = lower(b.email)
            )
    ) loop
        for xx in (
            select
                c.contact_id,
                c.created_by,
                status,
                start_date
            from
                contact      c,
                contact_role b
            where
                    lower(c.email) = x.email
                and c.contact_id = b.contact_id
        ) loop
            insert into contact_role (
                contact_role_id,
                contact_id,
                role_type,
                description,
                effective_date,
                effective_end_date,
                created_by,
                last_updated_by,
                cobra_id_number,
                ref_contact_id
            ) values ( contact_role_seq.nextval,
                       xx.contact_id,
                       case
                           when x.entity_type = 'CLIENTDIVISIONCONTACT' then
                               'COBRA_DIVISION'
                           else
                               'COBRA'
                       end,
                       case
                           when x.entity_type = 'CLIENTDIVISIONCONTACT' then
                               'Division Contact'
                           else
                               'Client Contact'
                       end,
                       xx.start_date,
                       case
                           when xx.status = 'I' then
                               sysdate
                           else
                               null
                       end,
                       xx.created_by,
                       xx.created_by,
                       x.cobra_id_number,
                       x.contact_id );

        end loop;
    end loop;

    for x in (
        select
            lower(email) email,
            entity_type,
            replace(
                replace(entity_id, '-'),
                ' '
            )            entity_id,
            cobra_id_number,
            created_by,
            contact_id,
            start_date,
            status,
            contact_type
        from
            contact a
        where
            entity_type in ( 'CLIENTDIVISIONCONTACT', 'CLIENTCONTACT' )
            and not exists (
                select
                    *
                from
                    contact b
                where
                        replace(
                            replace(b.entity_id, '-'),
                            ' '
                        ) = a.entity_id
                    and a.email = lower(b.email)
                    and entity_type = 'ENTERPRISE'
            )
    ) loop
        insert into contact_role (
            contact_role_id,
            contact_id,
            role_type,
            description,
            effective_date,
            effective_end_date,
            created_by,
            last_updated_by,
            cobra_id_number,
            ref_contact_id
        ) values ( contact_role_seq.nextval,
                   x.contact_id,
                   'COBRA',
                   case
                       when x.entity_type = 'CLIENTDIVISIONCONTACT' then
                           'Division Contact'
                       else
                           'Client Contact'
                   end,
                   x.start_date,
                   case
                       when x.status = 'I' then
                           sysdate
                       else
                           null
                   end,
                   x.created_by,
                   x.created_by,
                   x.cobra_id_number,
                   x.contact_id );

        if x.contact_type <> 'COBRA' then
            insert into contact_role (
                contact_role_id,
                contact_id,
                role_type,
                description,
                effective_date,
                effective_end_date,
                created_by,
                last_updated_by,
                cobra_id_number,
                ref_contact_id
            ) values ( contact_role_seq.nextval,
                       x.contact_id,
                       x.contact_type,
                       x.contact_type,
                       x.start_date,
                       case
                           when x.status = 'I' then
                               sysdate
                           else
                               null
                       end,
                       x.created_by,
                       x.created_by,
                       x.cobra_id_number,
                       x.contact_id );

        end if;

    end loop;

    for x in (
        select
            entity_type,
            replace(
                replace(entity_id, '-'),
                ' '
            ) entity_id,
            created_by,
            contact_id,
            start_date,
            status,
            contact_type
        from
            contact a
        where
            email is null
            and entity_type = 'ENTERPRISE'
    ) loop
        insert into contact_role (
            contact_role_id,
            contact_id,
            role_type,
            description,
            effective_date,
            effective_end_date,
            created_by,
            last_updated_by,
            ref_contact_id
        ) values ( contact_role_seq.nextval,
                   x.contact_id,
                   x.contact_type,
                   x.contact_type,
                   x.start_date,
                   case
                       when x.status = 'I' then
                           sysdate
                       else
                           null
                   end,
                   x.created_by,
                   x.created_by,
                   x.contact_id );

    end loop;

end;
/


-- sqlcl_snapshot {"hash":"5193b5584a7d3ea99033d8f1c41acb9168dd03b4","type":"PROCEDURE","name":"CONTACT_ROLE_MIGRATION","schemaName":"SAMQA","sxml":""}