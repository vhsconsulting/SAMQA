-- liquibase formatted sql
-- changeset SAMQA:1754373951724 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\ora73pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/ora73pkg.sql:null:969fe3c0540dc522d3810a7f82f26a29d2b5ebee:create

create or replace package body samqa.ora73pkg is

    file_pv utl_file.file_type;
   /* ---------------------------- LOCAL  MODULES -------------------------- */
    procedure parse_filename (
        name_in  in varchar2,
        dir_out  out varchar2,
        file_out out varchar2
    ) is
        dirsep_v char(1);
    begin
        if dbms_utility.port_string like '%WIN%' then
            dirsep_v := '\';
        else
            dirsep_v := '/';
        end if;

        dir_out := substr(name_in,
                          1,
                          instr(name_in, dirsep_v, -1, 1) - 1);

        file_out := substr(name_in,
                           instr(name_in, dirsep_v, -1, 1) + 1);

    end parse_filename;
   /* ---------------------------- PUBLIC MODULES -------------------------- */
    procedure open_file (
        filename_in in varchar2
    ) is

        file_v varchar2(100);
        dir_v  varchar2(100);
        mode_v char(1) := 'w';
    begin
        close_file;
        parse_filename(filename_in, dir_v, file_v);
        if
            dir_v is not null
            and file_v is not null
        then
            file_pv := utl_file.fopen(dir_v, file_v, mode_v);
        end if;

    end open_file;

    procedure close_file is
    begin
        if utl_file.is_open(file_pv) then
            utl_file.fclose(file_pv);
        end if;
    end close_file;

    procedure pl (
        line_in in varchar2
    ) is
    begin
        utl_file.put_line(file_pv, line_in);
        utl_file.fflush(file_pv);
    end pl;

end ora73pkg;
/

