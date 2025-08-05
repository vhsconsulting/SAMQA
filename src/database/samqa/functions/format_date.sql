create or replace function samqa.format_date (
    p_date varchar2
) return varchar2 is
    l_format_date varchar2(12) := null;
begin
    if p_date is not null then
        select
            decode(
                length(p_date),
                5,
                decode(
                    substr(p_date, 1, 1),
                    '0',
                    rpad(p_date, 6, '0'),
                    lpad(p_date, 6, '0')
                ),
                7,
                decode(
                    substr(p_date, 1, 1),
                    '0',
                    rpad(p_date, 8, '0'),
                    lpad(p_date, 8, '0')
                ),
                p_date
            )
        into l_format_date
        from
            dual;

    end if;

    return l_format_date;
end;
/


-- sqlcl_snapshot {"hash":"9e0c1801c4983b20fb6db21e444d86e84eb28670","type":"FUNCTION","name":"FORMAT_DATE","schemaName":"SAMQA","sxml":""}