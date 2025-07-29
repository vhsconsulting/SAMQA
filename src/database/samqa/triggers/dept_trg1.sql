create or replace editionable trigger samqa.dept_trg1 before
    insert on samqa.dept
    for each row
begin
    if :new.deptno is null then
        select
            dept_seq.nextval
        into :new.deptno
        from
            sys.dual;

    end if;
end;
/

alter trigger samqa.dept_trg1 enable;


-- sqlcl_snapshot {"hash":"8bad68d06bd6d021e1ad5559c3a9e6ca9421f4e0","type":"TRIGGER","name":"DEPT_TRG1","schemaName":"SAMQA","sxml":""}