-- liquibase formatted sql
-- changeset SAMQA:1754373928100 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\is_alphanumeric.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/is_alphanumeric.sql:null:92ae9037b76abedb3ba044e80293c481f780289a:create

create or replace function samqa.is_alphanumeric (
    p_string in varchar2
) return varchar2 is
    l_string varchar2(255);
begin
    select
        case
            when instr(
                    translate(p_string, '0123456789', '000000000'),
                    '0'
                ) > 1
                 and instr(
                translate(p_string, '~!@#$%^&*()_+?><":/', '000000000'),
                '0'
            ) = 0 then
                'AN'
            when instr(
                    translate(p_string, '0123456789', '000000000'),
                    '0'
                ) = 1
                 and instr(
                translate(p_string, '~!@#$%^&*()_+?><":/', '000000000'),
                '0'
            ) = 0 then
                'N'
            when instr(
                translate(p_string, '~!@#$%^&*()_+?><":/', '000000000'),
                '0'
            ) > 0 then
                'S'
            else
                'A'
        end
    into l_string
    from
        dual;

    return l_string;
end;
/

