create or replace editionable trigger samqa.employer_deivision_bf before
    insert or update on samqa.employer_divisions
    for each row
begin
    :new.division_code := upper(:new.division_code);
end;
/

alter trigger samqa.employer_deivision_bf enable;


-- sqlcl_snapshot {"hash":"46f5b9b33a0bdfa7e56dd2591513ded70121a15f","type":"TRIGGER","name":"EMPLOYER_DEIVISION_BF","schemaName":"SAMQA","sxml":""}