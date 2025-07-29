create or replace procedure samqa.koa_dependant (
    p_pers_main   in number,
    p_pers_id     in number,
    p_first_name  in varchar2,
    p_middle_name in varchar2,
    p_last_name   in varchar2,
    p_gender      in varchar2,
    p_ssn         in varchar2,
    p_dob         in date,
    p_relat_code  in varchar2
) is
begin
    if p_pers_id is null then
        insert into person (
            pers_id,
            pers_main,
            first_name,
            last_name,
            middle_name,
            gender,
            ssn,
            birth_date,
            relat_code
        ) values ( pers_seq.nextval,
                   p_pers_main,
                   p_first_name,
                   p_last_name,
                   p_middle_name,
                   p_gender,
                   p_ssn,
                   p_dob,
                   p_relat_code );

    else
        update person
        set
            first_name = p_first_name,
            last_name = p_last_name,
            middle_name = p_middle_name,
            gender = p_gender,
            ssn = p_ssn,
            birth_date = p_dob,
            relat_code = p_relat_code
        where
            pers_id = p_pers_id;

    end if;
end;
/


-- sqlcl_snapshot {"hash":"9f231309549f580a1358c294d470158b3e2e7561","type":"PROCEDURE","name":"KOA_DEPENDANT","schemaName":"SAMQA","sxml":""}