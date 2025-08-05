-- liquibase formatted sql
-- changeset SAMQA:1754373927277 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\format_to_date.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/format_to_date.sql:null:3bfde9da67393f567419d594f40c9964f5853c09:create

create or replace function samqa.format_to_date (
    p_in in varchar2
) return date is
    t_date date;
    l_in   varchar2(30);
begin
    if instr(p_in, '/') > 0 then
        if instr(p_in, '/', 1, 2) = 7 then
            t_date := to_date ( p_in, 'DD/MON/RRRR' );
        elsif ( instr(p_in, '/', 1, 2) = 6
        or instr(p_in, '/', 1, 1) = 2 ) then
            t_date := to_date ( p_in, 'MM/DD/RRRR' );
        elsif instr(p_in, '/', 1, 2) = 5 then
            l_in := substr(p_in, 1, 3)
                    || '0'
                    || substr(p_in, 4, 10);

            t_date := to_date ( l_in, 'MM/DD/RRRR' );
        elsif ( instr(p_in, '/', 1, 1) = 3 ) then
            t_date := to_date ( p_in, 'RR/MM/DD' );
        end if;
    end if;

    if instr(p_in, '-') > 0 then
        if length(p_in) = 23 then
            t_date := to_date ( substr(p_in, 1, 10), 'RRRR-MM-DD' );
        elsif instr(p_in, '-', 1, 2) = 7 then
            t_date := to_date ( p_in, 'DD-MON-RRRR' );
        elsif ( instr(p_in, '-', 1, 2) = 6
        or instr(p_in, '-', 1, 1) = 2 ) then
            t_date := to_date ( p_in, 'MM-DD-RRRR' );
        elsif ( instr(p_in, '-', 1, 1) = 5 ) then
            t_date := to_date ( p_in, 'RRRR-MM-DD' );
        elsif ( instr(p_in, '-', 1, 1) = 3 ) then
            t_date := to_date ( p_in, 'RR-MM-DD' );
        end if;

    end if;

    if instr(p_in, '.') > 0 then
        if instr(p_in, '.', 1, 2) = 7 then
            t_date := to_date ( p_in, 'DD.MON.RRRR' );
        elsif ( instr(p_in, '.', 1, 2) = 6
        or instr(p_in, '.', 1, 1) = 2 ) then
            t_date := to_date ( p_in, 'MM.DD.RRRR' );
        elsif ( instr(p_in, '.', 1, 1) = 5 ) then
            t_date := to_date ( p_in, 'RRRR.MM.DD' );
        elsif ( instr(p_in, '.', 1, 1) = 3 ) then
            t_date := to_date ( p_in, 'RR.MM.DD' );
        end if;
    end if;

    if
        instr(p_in, '/') = 0
        and instr(p_in, '-') = 0
    then
        if is_date(
            format_date(p_in),
            'MMDDRRRR'
        ) = 'Y' then
            t_date := to_date ( format_date(p_in), 'MMDDRRRR' );
        end if;

        if is_date(
            format_date(p_in),
            'RRRRMMDD'
        ) = 'Y' then
            t_date := to_date ( format_date(p_in), 'RRRRMMDD' );
        end if;

    end if;

    return t_date;
exception
    when others then
        pc_log.log_error('FORMAT_TO_DATE', p_in
                                           || ' '
                                           || sqlerrm);
        return null;
end;
/

