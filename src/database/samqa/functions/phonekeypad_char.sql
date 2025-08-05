create or replace function samqa.phonekeypad_char (
    str in varchar2
) return varchar2 is

    str_len varchar2(30);
    y       number(3);
    z       varchar2(30);
    l_var   varchar2(50) := null;
begin
    str_len := length(str);
    y := 1;
    while y <= str_len loop
        z := substr(str, y, 1);
        if z in ( 'A', 'B', 'C' ) then
            l_var := l_var || '2';
        elsif z in ( 'D', 'E', 'F' ) then
            l_var := l_var || '3';
        elsif z in ( 'G', 'H', 'I' ) then
            l_var := l_var || '4';
        elsif z in ( 'J', 'K', 'L' ) then
            l_var := l_var || '5';
        elsif z in ( 'M', 'N', 'O' ) then
            l_var := l_var || '6';
        elsif z in ( 'P', 'Q', 'R', 'S' ) then
            l_var := l_var || '7';
        elsif z in ( 'V', 'T', 'U' ) then
            l_var := l_var || '8';
        elsif z in ( 'W', 'X', 'Y', 'Z' ) then
            l_var := l_var || '9';
        end if;

        y := y + 1;
    end loop;

    return ( l_var );
end;
/


-- sqlcl_snapshot {"hash":"3edec50d65938bac4b294f41ae76703012cb8f41","type":"FUNCTION","name":"PHONEKEYPAD_CHAR","schemaName":"SAMQA","sxml":""}