-- liquibase formatted sql
-- changeset SAMQA:1754373927187 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\format_date.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/format_date.sql:null:9e0c1801c4983b20fb6db21e444d86e84eb28670:create

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

