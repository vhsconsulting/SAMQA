-- liquibase formatted sql
-- changeset SAMQA:1754373928166 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\notes_list.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/notes_list.sql:null:27242af1460f9b7b860c5a2e128f7246d387cac9:create

create or replace function samqa.notes_list (
    p_note_id in number
) return varchar2_4000_tbl as

    l_tab  varchar2_4000_tbl := varchar2_4000_tbl();
    l_text varchar2(32767);
    l_part varchar2(32767);
    l_idx  number;
begin
    for x in (
        select
            description
        from
            notes
        where
            note_id = p_note_id
    ) loop
        l_text := x.description;
    end loop;

    loop
  /*  l_idx :=  REGEXP_INSTR(l_text,REGEXP_SUBSTR( l_text
		       , '([[:digit:]]{1,2})+(\.|\-|\/)+([[:digit:]]{1,2})+(\.|\-|\/)([[:digit:]]{1,2})+\',1,1));

    l_tab.extend;

    l_tab(l_tab.last) :=SUBSTR(l_text, REGEXP_INSTR(l_text,REGEXP_SUBSTR( l_text
		       , '([[:digit:]]{1,2})+(\.|\-|\/)+([[:digit:]]{1,2})+(\.|\-|\/)([[:digit:]]{1,2})+\',1,1))  ,
		       REGEXP_INSTR(l_text,REGEXP_SUBSTR( l_text
		       , '([[:digit:]]{1,2})+(\.|\-|\/)+([[:digit:]]{1,2})+(\.|\-|\/)([[:digit:]]{1,2})+\',1,2)) -2
		       );
    l_text :=  SUBSTR(l_text,
			REGEXP_INSTR(l_text,REGEXP_SUBSTR( l_text
		       , '([[:digit:]]{1,2})+(\.|\-|\/)+([[:digit:]]{1,2})+(\.|\-|\/)([[:digit:]]{1,2})+\',1,2)) -1,LENGTH(l_text))
		;
    EXIT when NVL(L_IDX, 0) = 0;*/

        l_idx := instr(l_text,
                       chr(10));
        exit when nvl(l_idx, 0) = 0;
        if strip_bad(trim(substr(l_text, 1, l_idx - 1))) <> ' ' then
            l_tab.extend;
            l_tab(l_tab.last) := trim(substr(l_text, 1, l_idx - 1));

        end if;

        l_text := substr(l_text, l_idx + 1);
    end loop;

    if strip_bad(l_text) <> ' ' then
        l_tab.extend;
        l_tab(l_tab.last) := l_text;
    end if;

    return l_tab;
end;
/

