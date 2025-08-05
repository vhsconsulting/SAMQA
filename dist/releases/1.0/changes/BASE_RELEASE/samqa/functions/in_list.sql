-- liquibase formatted sql
-- changeset SAMQA:1754373928075 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\in_list.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/in_list.sql:null:0aa7774232e2e1f7735dfd21d45ec7a4fd606034:create

create or replace function samqa.in_list (
    p_in_list   in varchar2,
    p_delimiter in varchar2 default null
) return varchar2_4000_tbl as

    l_tab  varchar2_4000_tbl := varchar2_4000_tbl();
    l_text varchar2(32767) := p_in_list || p_delimiter;
    l_idx  number;
begin
    loop
        l_idx := instr(l_text, p_delimiter);
        exit when nvl(l_idx, 0) = 0;
        l_tab.extend;
        l_tab(l_tab.last) := trim(substr(l_text, 1, l_idx - 1));

        l_text := substr(l_text, l_idx + 1);
    end loop;

    return l_tab;
end;
/

