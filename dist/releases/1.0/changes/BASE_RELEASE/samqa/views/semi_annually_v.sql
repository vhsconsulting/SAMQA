-- liquibase formatted sql
-- changeset SAMQA:1754374178679 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\semi_annually_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/semi_annually_v.sql:null:8518a22e0e61d282dc341de767a8de4ddb1e0b10:create

create or replace force editionable view samqa.semi_annually_v (
    rn,
    q_end
) as
    select
        rownum rn,
        add_months(
            trunc(sysdate, 'yyyy'),
            rownum * 6
        )      q_end
    from
        all_objects
    where
        rownum <= 2;

