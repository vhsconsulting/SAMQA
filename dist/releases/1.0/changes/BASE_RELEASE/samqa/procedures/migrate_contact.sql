-- liquibase formatted sql
-- changeset SAMQA:1754374144504 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\migrate_contact.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/migrate_contact.sql:null:42f3f439235cdebb0f66e899321d9157c0fdfed8:create

create or replace procedure samqa.migrate_contact (
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
            b.email,
            a.entrp_email,
            a.entrp_contact,
            b.user_id,
            c.start_date,
            regexp_count(a.entrp_contact, ' '),
            b.emp_reg_type
        from
            enterprise   a,
            online_users b,
            account      c
        where
                replace(a.entrp_code, '-') = p_tax_id
            and replace(a.entrp_code, '-') = b.tax_id
            and a.entrp_id = c.entrp_id
            and b.user_type = 'E'
            and regexp_count(a.entrp_contact, ' ') >= 1
    ) loop
        l_count := 0;
        l_enroll_count := 0;
        select
            count(*)
        into l_count
        from
            contact
        where
            user_id = x.user_id;

        if x.emp_reg_type = '1' then
            select
                count(*)
            into l_enroll_count
            from
                contact      a,
                online_users b
            where
                    a.user_id = b.user_id
                and b.emp_reg_type = '1'
                and b.tax_id = p_tax_id;

        end if;

        if
            l_count = 0
            and l_enroll_count = 0
        then
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
                user_id,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
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
                       'Migrating from Employer',
                       x.user_id,
                       sysdate,
                       0,
                       sysdate,
                       0 );

        end if;

    end loop;
end;
/

