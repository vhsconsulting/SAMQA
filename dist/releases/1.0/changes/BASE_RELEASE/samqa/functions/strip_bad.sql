-- liquibase formatted sql
-- changeset SAMQA:1754373928564 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\strip_bad.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/strip_bad.sql:null:660cc97cf07791151f05e575353424b699ce68eb:create

create or replace function samqa.strip_bad (
    p_string in varchar2
) return varchar2
    deterministic
is
    g_bad_chars  varchar2(256);
    g_a_bad_char varchar2(256);
    x_string     varchar2(3200);
begin
    for i in 0..255 loop
        if (
            i not between ascii('a') and ascii('z')
            and i not between ascii('A') and ascii('Z')
            and i not between ascii('0') and ascii('9')
            and i <> ascii('#')
            and i <> ascii('-')
            and i <> ascii('|')
            and i <> ascii('/')
            and i <> ascii('''')
        ) then
            g_bad_chars := g_bad_chars || chr(i);
        end if;
    end loop;

    g_a_bad_char := rpad(
        substr(g_bad_chars, 1, 1),
        length(g_bad_chars),
        substr(g_bad_chars, 1, 1)
    );

    x_string := replace(
        translate(p_string, g_bad_chars, g_a_bad_char),
        substr(g_a_bad_char, 1, 1),
        ' '
    );

    x_string := replace(
        replace(x_string, ''''),
        '/'
    );
    x_string := replace(
        replace(x_string, ' '),
        ''
    );
    return x_string;
end;
/

