-- liquibase formatted sql
-- changeset SAMQA:1754374003120 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_employer_divisions.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_employer_divisions.sql:null:66feb40ebb2b3d6baa15bab5750dd5ac364d93fa:create

create or replace package body samqa.pc_employer_divisions as

    procedure insert_employer_divisions (
        p_division_code in varchar2,
        p_division_name in varchar2,
        p_description   in varchar2,
        p_entrp_id      in number,
        p_division_main in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
    begin
        x_return_status := 'S';
       /** If there is no division with division code then create new **/

        if get_division_count(p_entrp_id, p_division_code) = 0 then
            insert into employer_divisions (
                division_id,
                division_code,
                division_name,
                description,
                entrp_id,
                division_main,
                status,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            ) values ( employer_divisions_seq.nextval,
                       upper(p_division_code),
                       p_division_name,
                       p_description,
                       p_entrp_id,
                       p_division_main,
                       'A',
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_user_id );

        else
            x_return_status := 'E';
            x_error_message := 'Division exists with same Division Code, try creating with different division code';
        end if;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end insert_employer_divisions;

    procedure update_employer_divisions (
        p_division_id   in number,
        p_division_code in varchar2,
        p_division_name in varchar2,
        p_description   in varchar2,
        p_entrp_id      in number,
        p_division_main in number,
        p_status        in varchar2,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
    begin
        x_return_status := 'S';
        if p_division_id is not null then
            update employer_divisions
            set
                division_name = nvl(p_division_name, division_name),
                division_code = nvl(p_division_code, division_code)  -- rprabu Ticket #9198 02/12/2020
                ,
                description = nvl(p_description, description),
                division_main = nvl(p_division_main, division_main),
                status = nvl(p_status, status),
                last_updated_by = p_user_id,
                last_update_date = sysdate
            where
                division_id = p_division_id;

        end if;

        if
            p_division_id is null
            and p_division_code is not null
        then
            update employer_divisions
            set
                division_name = nvl(p_division_name, division_name),
                description = nvl(p_description, description),
                division_main = nvl(p_division_main, division_main),
                status = nvl(p_status, status),
                division_code = nvl(p_division_code, division_code)  -- rprabu Ticket #9198 02/12/2020
                ,
                last_updated_by = p_user_id,
                last_update_date = sysdate
            where
                    division_code = upper(p_division_code)
                and division_id = p_division_id;

        end if;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end update_employer_divisions;

    procedure reassign_division (
        p_division_code in varchar2,
        p_acc_id        in number,
        p_entrp_id      in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
    begin
        x_return_status := 'S';
        update person
        set
            division_code = upper(p_division_code),
            last_updated_by = p_user_id,
            last_update_date = sysdate
        where
                pers_id = (
                    select
                        pers_id
                    from
                        account
                    where
                        acc_id = p_acc_id
                )
            and entrp_id = p_entrp_id;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end reassign_division;

    procedure delete_employer_divisions (
        p_division_id in number,
        p_user_id     in number
    ) is
        l_division_code varchar2(30);
        l_entrp_id      number;
    begin
        for x in (
            select
                division_code,
                entrp_id
            from
                employer_divisions
            where
                division_id = p_division_id
        ) loop
            l_division_code := upper(x.division_code);
            l_entrp_id := x.entrp_id;
        end loop;

/** As per mockup,
   Clicking the delete icon on an existing division should pop up message
   "Are you sure you wish to delete this division?
   All employees in this division will revert to 'None' as their division." ***/

        update person
        set
            division_code = null
        where
                division_code = l_division_code
            and entrp_id = l_entrp_id;

        delete from employer_divisions
        where
            division_id = p_division_id;

    end delete_employer_divisions;

    function get_division_count (
        p_entrp_id      in number,
        p_division_code in varchar2
    ) return number is
        l_division_count number := 0;
    begin
        select
            count(*)
        into l_division_count
        from
            employer_divisions
        where
                entrp_id = p_entrp_id
            and division_code = upper(p_division_code);

        return l_division_count;
    exception
        when others then
            return 0;
    end get_division_count;

    function get_employee_count (
        p_entrp_id      in number,
        p_division_code in varchar2
    ) return number is
        l_employee_count number := 0;
    begin
        if p_division_code is not null then
            select
                count(*)
            into l_employee_count
            from
                person
            where
                    entrp_id = p_entrp_id
                and division_code = upper(p_division_code);

        else
            select
                count(*)
            into l_employee_count
            from
                person
            where
                    entrp_id = p_entrp_id
                and division_code is null;

        end if;

        return l_employee_count;
    exception
        when others then
            return 0;
    end get_employee_count;

    function get_division_code (
        p_pers_id  in number,
        p_entrp_id in number
    ) return varchar2 is
        l_division_name varchar2(30);
    begin
        select
            division_name
        into l_division_name
        from
            employer_divisions a,
            person             c
        where
                c.entrp_id = a.entrp_id
            and c.pers_id = p_pers_id
            and c.entrp_id = p_entrp_id
            and c.division_code = a.division_code;

        return l_division_name;
    end get_division_code;

    procedure insert_employer_division (
        p_division_code in varchar2,
        p_division_name in varchar2,
        p_description   in varchar2,
        p_address1      in varchar2,
        p_address2      in varchar2,
        p_city          in varchar2,
        p_state         in varchar2,
        p_zip           in varchar2,
        p_phone         in varchar2,
        p_fax           in varchar2,
        p_vendor_ref    in varchar2,
        p_vendor        in varchar2,
        p_entrp_id      in number,
        p_user_id       in number,
        x_division_id   out number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        l_division_id number;
    begin
        x_return_status := 'S';
       /** If there is no division with division code then create new **/

        if get_division_count(p_entrp_id, p_division_code) = 0 then
            insert into employer_divisions (
                division_id,
                division_code,
                division_name,
                description,
                address1,
                address2,
                city,
                state,
                zip,
                phone,
                fax,
                cobra_id_number,
                entrp_id,
                status,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by
            ) values ( employer_divisions_seq.nextval,
                       upper(p_division_code),
                       p_division_name,
                       p_description,
                       p_address1,
                       p_address2,
                       p_city,
                       p_state,
                       p_zip,
                       p_phone,
                       p_fax,
                       case
                           when p_vendor = 'COBRA' then
                               p_vendor_ref
                           else
                               null
                       end,
                       p_entrp_id,
                       'A',
                       sysdate,
                       p_user_id,
                       sysdate,
                       p_user_id ) returning division_id into x_division_id;

        else
            x_return_status := 'E';
            x_error_message := 'Division exists with same Division Code, try creating with different division code';
        end if;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end insert_employer_division;

    function get_division_id_for_cobra (
        p_cobra_number in number
    ) return number is
        l_division_id number;
    begin
        for x in (
            select
                division_id
            from
                employer_divisions
            where
                cobra_id_number = p_cobra_number
        ) loop
            l_division_id := x.division_id;
        end loop;

        return l_division_id;
    exception
        when others then
            null;
    end;

    function get_division_name (
        p_division_code in varchar2,
        p_entrp_id      in number
    ) return varchar2 is
        l_division_name varchar2(3200);
    begin
        select
            division_name
        into l_division_name
        from
            employer_divisions b
        where
                b.division_code = p_division_code
            and b.entrp_id = p_entrp_id;

        return l_division_name;
    exception
        when others then
            return null;
    end get_division_name;

end pc_employer_divisions;
/

