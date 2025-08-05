-- liquibase formatted sql
-- changeset SAMQA:1754374165186 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\emp_trg1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/emp_trg1.sql:null:ce709ebfd5e6f66533f76d1c3ac185babdb4bd3d:create

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

