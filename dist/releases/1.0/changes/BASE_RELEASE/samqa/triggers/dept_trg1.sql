-- liquibase formatted sql
-- changeset SAMQA:1754374165172 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\dept_trg1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/dept_trg1.sql:null:caaf394d6199e5220bf819a8e6d75a29c03ef124:create

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

