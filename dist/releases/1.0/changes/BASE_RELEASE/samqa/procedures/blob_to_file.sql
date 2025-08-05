-- liquibase formatted sql
-- changeset SAMQA:1754374142611 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\blob_to_file.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/blob_to_file.sql:null:ad565d4676432dfb1a40f8bbc44ff0db4b5ba4c2:create

create or replace procedure samqa.blob_to_file (
    p_file_name in varchar2
) is

    l_out_file utl_file.file_type;
    l_buffer   raw(32767);
    l_amount   binary_integer := 32767;
    l_pos      integer := 1;
    l_blob_len integer;
    p_data     blob;
    file_name  varchar2(256);
begin
    for rec in (
        select
            id
        from
            apex_application_files
        where
            name = p_file_name
    ) loop
        select
            blob_content,
            replace(filename, ' ')
        into
            p_data,
            file_name
        from
            apex_application_files
        where
            id = rec.id;
        --
        l_blob_len := dbms_lob.getlength(p_data);
        l_out_file := utl_file.fopen('WEBSITE_FORMS_DIR', file_name, 'wb', 32767);
        --
        while l_pos < l_blob_len loop
            dbms_lob.read(p_data, l_amount, l_pos, l_buffer);
            if l_buffer is not null then
                utl_file.put_raw(l_out_file, l_buffer, true);
            end if;

            l_pos := l_pos + l_amount;
        end loop;
        --
        utl_file.fclose(l_out_file);
        --------------
    end loop;
exception
    when others then
        if utl_file.is_open(l_out_file) then
            utl_file.fclose(l_out_file);
        end if;
end;
/

