create or replace function samqa.emailvalidate_v1 (
    email varchar2
) return number is

    t_valid    number(1);
    t_totallen number(2);
    t_counter  number(2) := 0;
    t_atpos    number(2) := 1;
    i          number(2) := 1;
    t_pointpos number(2) := 1;
    mail_ch    varchar2(1);
begin
    t_totallen := length(email);
    t_counter := t_totallen;
    i := 1;
    t_valid := 1;

-------------------------------------------------------------------------------------

    if length(ltrim(rtrim(email))) = 0 then
        t_valid := 0;
    else
---------------------------------------------------------------------------------------
	--This is to check special characters are present or not in the email ID
        t_counter := t_totallen;
        while t_counter > 0 loop
            mail_ch := substr(email, i, 1);
            i := i + 1;
            t_counter := t_counter - 1;
            if mail_ch in ( ' ', '!', '#', '$', '%',
                            '^', '&', '*', '(', ')',
                            '-', '', '"', '+', '|',
                            '{', '}', '[', ']', ':',
                            '>', '<', '?', '/', '\',
                            '=' ) then
                t_valid := 0;
                exit;
            end if;

        end loop;

	---------------------------------------------------------------------------------------
	--This is to check more than one '@' character present or not

        t_atpos := instr(email, '@', 1, 2);
        if t_atpos > 1 then
            t_valid := 0;
        end if;

	---------------------------------------------------------------------------------------
	--This is to check at minimum and at maximum only one '@' character present

        t_atpos := instr(email, '@', 1);
        if t_atpos in ( 0, 1 ) then
            t_valid := 0;
        end if;

	---------------------------------------------------------------------------------------
	--This is to check at least one '.' character present or not

        t_pointpos := instr(email, '.', 1);
        if t_pointpos in ( 0, 1 ) then
            t_valid := 0;
        end if;

	---------------------------------------------------------------------------------------

    end if;

    return t_valid;
end;
/


-- sqlcl_snapshot {"hash":"529d283ff060378a575d705a61d2509a8217edbd","type":"FUNCTION","name":"EMAILVALIDATE_V1","schemaName":"SAMQA","sxml":""}