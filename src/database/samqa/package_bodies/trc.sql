create or replace package body samqa.trc is

    type_pv     varchar2(100);
    name_pv     varchar2(100);
    spooling_pv boolean;

   /* ---------------------------- PUBLIC MODULES -------------------------- */
    procedure spool_on (
        type_in in varchar2,
        name_in varchar2 := null
    ) is
        type_v type_pv%type := upper(type_in);
    begin
      /* close previous file */
        if type_pv = file_pc then
            ora73pkg.close_file;
        end if;
        if type_v = file_pc then
            ora73pkg.open_file(name_in);
        end if;
        type_pv := type_v;
        name_pv := name_in;
        spooling_pv := true;
    end spool_on;

    procedure spool_off is
    begin
        spooling_pv := false;
        if type_pv = file_pc then
            ora73pkg.close_file;
        end if;
    end spool_off;

    procedure pl (
        line_in in varchar2
    ) is
        status_v number;
    begin
        if spooling_pv then
            if type_pv = screen_pc then
                dbms_output.put_line(line_in);
            elsif type_pv = pipe_pc then
--            DBMS_PIPE.PACK_MESSAGE (line_in);
--            status_v := DBMS_PIPE.SEND_MESSAGE (name_pv);
                null;
            elsif type_pv = file_pc then
                ora73pkg.pl(line_in);
            elsif type_pv = table_pc then
                ora81pkg.pl(line_in);
            end if;

        end if;
    end pl;

    procedure pl (
        num_in in number
    ) is
    begin
        pl(to_char(num_in));
    end pl;

    procedure pl (
        date_in in date
    ) is
    begin
        pl(to_char(date_in));
    end pl;

    procedure pl (
        bool_in in boolean
    ) is
    begin
        pl(pc_util.bool2char(bool_in));
    end pl;

    procedure pl (
        str_in in varchar2,
        num_in in number
    ) is
    begin
        pl(str_in
           || ': '
           || to_char(num_in));
    end pl;

    procedure pl (
        str_in  in varchar2,
        date_in in date
    ) is
    begin
        pl(str_in
           || ': '
           || to_char(date_in));
    end pl;

    procedure pl (
        str_in  in varchar2,
        bool_in in boolean
    ) is
    begin
        pl(str_in
           || ': '
           || pc_util.bool2char(bool_in));
    end pl;

begin
    spool_on(screen_pc);
end trc;
/


-- sqlcl_snapshot {"hash":"af4a64a761c88ff8019a4aa41802a12eda5fcdc8","type":"PACKAGE_BODY","name":"TRC","schemaName":"SAMQA","sxml":""}