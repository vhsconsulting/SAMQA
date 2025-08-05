create or replace editionable trigger samqa.emp_trg1 before
    insert on samqa.emp
    for each row
begin
    if :new.empno is null then
        select
            emp_seq.nextval
        into :new.empno
        from
            sys.dual;

    end if;
end;
/

alter trigger samqa.emp_trg1 enable;


-- sqlcl_snapshot {"hash":"fdfb384d8102c7daa622ee28e77f0a80b7c11d67","type":"TRIGGER","name":"EMP_TRG1","schemaName":"SAMQA","sxml":""}